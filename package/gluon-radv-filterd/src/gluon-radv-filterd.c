/*
   Copyright (c) 2016 Jan-Philipp Litza <janphilipp@litza.de>
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#define _GNU_SOURCE
#include <errno.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <sys/socket.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <net/if.h>

#include <linux/filter.h>
#include <linux/if_packet.h>
#include <linux/limits.h>

#include <netinet/icmp6.h>
#include <netinet/in.h>
#include <netinet/ip6.h>

#include "mac.h"

// Recheck TQs after this time even if no RA was received
#define MAX_INTERVAL 60

// Recheck TQs at most this often, even if new RAs were received (they won't
// become the preferred routers until the TQs have been rechecked)
// Also, the first update will take at least this long
#define MIN_INTERVAL 15

// max execution time of a single ebtables call in nanoseconds
#define EBTABLES_TIMEOUT 500000000 // 500ms

// TQ value assigned to local routers
#define LOCAL_TQ 512

#define BUFSIZE 1500

#define DEBUGFS "/sys/kernel/debug/batman_adv/%s/"
#define ORIGINATORS DEBUGFS "originators"
#define TRANSTABLE_GLOBAL DEBUGFS "transtable_global"
#define TRANSTABLE_LOCAL DEBUGFS "transtable_local"

#ifdef DEBUG
#define CHECK(stmt) \
    if(!(stmt)) { \
        fprintf(stderr, "check failed: " #stmt "\n"); \
        goto check_failed; \
    }
#define DEBUG_MSG(msg, ...) fprintf(stderr, msg "\n", ##__VA_ARGS__)
#else
#define CHECK(stmt) if(!(stmt)) goto check_failed;
#define DEBUG_MSG(msg, ...) do {} while(0)
#endif

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(A) (sizeof(A)/sizeof(A[0]))
#endif

#define foreach(item, list) \
	for(item = list; item != NULL; item = item->next)

struct router {
	struct router *next;
	macaddr_t src;
	time_t eol;
	macaddr_t originator;
	uint16_t tq;
};

struct global {
	int sock;
	struct router *routers;
	const char *mesh_iface;
	const char *chain;
	uint16_t max_tq;
	uint16_t hysteresis_thresh;
	struct router *best_router;
} G = {
	.mesh_iface = "bat0",
};


static void error_message(int status, int errnum, char *message, ...) {
	va_list ap;
	va_start(ap, message);
	fflush(stdout);
	vfprintf(stderr, message, ap);
	if (errnum)
		fprintf(stderr, ": %s", strerror(errnum));
	fprintf(stderr, "\n");
	if (status)
		exit(status);
}

static void cleanup() {
	struct router *router;
	close(G.sock);

	while (G.routers != NULL) {
		router = G.routers;
		G.routers = router->next;
		free(router);
	}
}

static void usage(const char *msg) {
	if (msg != NULL && *msg != '\0') {
		fprintf(stderr, "ERROR: %s\n\n", msg);
	}
	fprintf(stderr,
		"Usage: %s [-m <mesh_iface>] [-t <thresh>] -c <chain> -i <iface>\n\n"
		"  -m <mesh_iface>  B.A.T.M.A.N. advanced mesh interface used to get metric\n"
		"                   information (\"TQ\") for the available gateways. Default: bat0\n"
		"  -t <thresh>      Minimum TQ difference required to switch the gateway.\n"
		"                   Default: 0\n"
		"  -c <chain>       ebtables chain that should be managed by the daemon. The\n"
		"                   chain already has to exist on program invocation and should\n"
		"                   have a DROP policy. It will be flushed by the program!\n"
		"  -i <iface>       Interface to listen on for router advertisements. Should be\n"
		"                   <mesh_iface> or a bridge on top of it, as no metric\n"
		"                   information will be available for hosts on other interfaces.\n\n",
		program_invocation_short_name);
	cleanup();
	if (msg == NULL)
		exit(EXIT_SUCCESS);
	else
		exit(EXIT_FAILURE);
}

#define exit_errmsg(message, ...) { \
	fprintf(stderr, message "\n", ##__VA_ARGS__); \
	cleanup(); \
	exit(1); \
	}

static inline void exit_errno(const char *message) {
	cleanup();
	error_message(1, errno, "error: %s", message);
}

static inline void warn_errno(const char *message) {
	error_message(0, errno, "warning: %s", message);
}

static int init_packet_socket(unsigned int ifindex) {
	struct sock_filter radv_filter_code[] = {
		// check that this is an ICMPv6 packet
		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, offsetof(struct ip6_hdr, ip6_nxt)),
		BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, IPPROTO_ICMPV6, 0, 7),
		// check that this is a router advertisement
		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, sizeof(struct ip6_hdr) + offsetof(struct icmp6_hdr, icmp6_type)),
		BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, ND_ROUTER_ADVERT, 0, 5),
		// check that the code field in the ICMPv6 header is 0
		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, sizeof(struct ip6_hdr) + offsetof(struct nd_router_advert, nd_ra_code)),
		BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 0, 3),
		// check that this is a default route (lifetime > 0)
		BPF_STMT(BPF_LD|BPF_H|BPF_ABS, sizeof(struct ip6_hdr) + offsetof(struct nd_router_advert, nd_ra_router_lifetime)),
		BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 1, 0),
		// return true
		BPF_STMT(BPF_RET|BPF_K, 0xffffffff),
		// return false
		BPF_STMT(BPF_RET|BPF_K, 0),
	};

	struct sock_fprog radv_filter = {
	    .len = ARRAY_SIZE(radv_filter_code),
	    .filter = radv_filter_code,
	};

	int sock = socket(AF_PACKET, SOCK_DGRAM|SOCK_CLOEXEC, htons(ETH_P_IPV6));
	if (sock < 0)
		exit_errno("can't open packet socket");
	int ret = setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER, &radv_filter, sizeof(radv_filter));
	if (ret < 0)
		exit_errno("can't attach socket filter");

	struct sockaddr_ll bind_iface = {
		.sll_family = AF_PACKET,
		.sll_protocol = htons(ETH_P_IPV6),
		.sll_ifindex = ifindex,
	};
	bind(sock, (struct sockaddr *)&bind_iface, sizeof(bind_iface));

	return sock;
}

static void parse_cmdline(int argc, char *argv[]) {
	int c;
	unsigned int ifindex;
	unsigned long int threshold;
	char *endptr;
	while ((c = getopt(argc, argv, "c:hi:m:t:")) != -1) {
		switch (c) {
			case 'i':
				if (G.sock != 0)
					usage("-i given more than once");
				ifindex = if_nametoindex(optarg);
				if (ifindex == 0)
					exit_errmsg("Unknown interface: %s", optarg);
				G.sock = init_packet_socket(ifindex);
				break;
			case 'm':
				G.mesh_iface = optarg;
				break;
			case 'c':
				G.chain = optarg;
				break;
			case 't':
				threshold = strtoul(optarg, &endptr, 10);
				if (*endptr != '\0')
					exit_errmsg("Threshold must be a number: %s", optarg);
				if (threshold >= LOCAL_TQ)
					exit_errmsg("Threshold too large: %ld (max is %d)", threshold, LOCAL_TQ);
				G.hysteresis_thresh = (uint16_t) threshold;
				break;
			case 'h':
				usage(NULL);
				break;
			default:
				usage("");
				break;
		}
	}
}

static void handle_ra(int sock) {
	struct sockaddr_ll src;
	unsigned int addr_size = sizeof(src);
	size_t len;
	struct {
		struct ip6_hdr ip6;
		struct nd_router_advert ra;
	} pkt;

	len = recvfrom(sock, &pkt, sizeof(pkt), 0, (struct sockaddr *)&src, &addr_size);

	// BPF already checked that this is an ICMPv6 RA of a default router
	CHECK(len >= sizeof(pkt));
	CHECK(ntohs(pkt.ip6.ip6_plen) + sizeof(struct ip6_hdr) >= sizeof(pkt));

	DEBUG_MSG("received valid RA from " F_MAC, F_MAC_VAR(src.sll_addr));

	// update list of known routers
	struct router *router;
	foreach(router, G.routers) {
		if (!memcmp(router->src, src.sll_addr, sizeof(macaddr_t))) {
			break;
		}
	}
	if (!router) {
		router = malloc(sizeof(struct router));
		memcpy(router->src, src.sll_addr, sizeof(router->src));
		router->next = G.routers;
		G.routers = router;
	}
	router->eol = time(NULL) + pkt.ra.nd_ra_router_lifetime;

check_failed:
	return;
}

static void expire_routers() {
	struct router **prev_ptr = &G.routers;
	struct router *router;
	time_t now = time(NULL);

	foreach(router, G.routers) {
		if (router->eol < now) {
			DEBUG_MSG("router " F_MAC " expired", F_MAC_VAR(router->src));
			*prev_ptr = router->next;
			if (G.best_router == router)
				G.best_router = NULL;
			free(router);
		} else {
			prev_ptr = &router->next;
		}
	}
}

static void update_tqs() {
	FILE *f;
	struct router *router;
	char path[PATH_MAX];
	char *line = NULL;
	size_t len = 0;
	uint8_t tq;
	bool update_originators = false;
	int i;
	macaddr_t mac_a, mac_b;
	macaddr_t unspec = {};

	// reset TQs
	foreach(router, G.routers) {
		router->tq = 0;
		if (!memcmp(router->originator, unspec, sizeof(unspec)))
			update_originators = true;
	}

	// TODO: Currently, we iterate over the whole list of routers all the
	// time. Maybe it would be a good idea to sort routers that already
	// have the current piece of information to the back. That way, we
	// could abort as soon as we hit the first router with the current
	// information filled in.

	if (update_originators) {
		// translate all router's MAC addresses to originators simultaneously
		snprintf(path, PATH_MAX, TRANSTABLE_GLOBAL, G.mesh_iface);
		f = fopen(path, "r");
		// skip header
		while (fgetc(f) != '\n') {}
		while (fgetc(f) != '\n') {}
		while (fscanf(f, " %*[*+] " F_MAC "%*[0-9 -] (%*3u) via " F_MAC " %*[^]]]\n",
				F_MAC_VAR_REF(mac_a), F_MAC_VAR_REF(mac_b)) == 12) {

			foreach(router, G.routers) {
				if (!memcmp(router->src, mac_a, sizeof(macaddr_t))) {
					DEBUG_MSG("Found originator for " F_MAC ", it's " F_MAC, F_MAC_VAR(router->src), F_MAC_VAR(mac_b));
					memcpy(router->originator, mac_b, sizeof(macaddr_t));
					break; // foreach
				}
			}
		}
		if (!feof(f)) {
			getline(&line, &len, f);
			fprintf(stderr, "Parsing transtable_global aborted at this line: %s\n", line);
		}
		fclose(f);
	}

	// look up TQs of originators
	G.max_tq = 0;
	snprintf(path, PATH_MAX, ORIGINATORS, G.mesh_iface);
	f = fopen(path, "r");
	// skip header
	while (fgetc(f) != '\n');
	while (fgetc(f) != '\n');
	while (fscanf(f, F_MAC " %*fs (%hhu) %*[^\n]\n",
			F_MAC_VAR_REF(mac_a), &tq) == 7) {

		foreach(router, G.routers) {
			if (!memcmp(router->originator, mac_a, sizeof(macaddr_t))) {
				DEBUG_MSG("Found TQ for router " F_MAC " (originator " F_MAC "), it's %d", F_MAC_VAR(router->src), F_MAC_VAR(router->originator), tq);
				router->tq = tq;
				if (tq > G.max_tq)
					G.max_tq = tq;
				break; // foreach
			}
		}
	}
	if (!feof(f)) {
		getline(&line, &len, f);
		fprintf(stderr, "Parsing originators aborted at this line: %s\n", line);
	}
	fclose(f);

	// if all routers have a TQ value, we don't need to check translocal
	foreach(router, G.routers) {
		if (router->tq == 0)
			break;
	}
	if (router != NULL) {
		// rate local routers (if present) the highest
		snprintf(path, PATH_MAX, TRANSTABLE_LOCAL, G.mesh_iface);
		f = fopen(path, "r");
		// skip header
		while (fgetc(f) != '\n');
		while (fgetc(f) != '\n');
		while (fscanf(f, " * " F_MAC " [%*5s] %*f", F_MAC_VAR_REF(mac_a)) == 6) {
			foreach(router, G.routers) {
				if (!memcmp(router->src, mac_a, sizeof(macaddr_t))) {
					DEBUG_MSG("Found router " F_MAC " in transtable_local, assigning TQ %d", F_MAC_VAR(router->src), LOCAL_TQ);
					router->tq = LOCAL_TQ;
					G.max_tq = LOCAL_TQ;
					break; // foreach
				}
			}
		}
		if (!feof(f)) {
			getline(&line, &len, f);
			fprintf(stderr, "Parsing transtable_local aborted at this line: %s\n", line);
		}
		fclose(f);
	}

	foreach(router, G.routers) {
		if (router->tq == 0) {
			if (!memcmp(router->originator, unspec, sizeof(unspec)))
				fprintf(stderr,
					"Unable to find router " F_MAC " in transtable_{global,local}\n",
					F_MAC_VAR(router->src));
			else
				fprintf(stderr,
					"Unable to find TQ for originator " F_MAC " (router " F_MAC ")\n",
					F_MAC_VAR(router->originator),
					F_MAC_VAR(router->src));
		}
	}

	free(line);
}

static int fork_execvp_timeout(struct timespec *timeout, const char *file, const char *const argv[]) {
	int ret;
	pid_t child;
	siginfo_t info;
	sigset_t signals, oldsignals;
	sigemptyset(&signals);
	sigaddset(&signals, SIGCHLD);

	sigprocmask(SIG_BLOCK, &signals, &oldsignals);
	child = fork();
	if (child == 0) {
		sigprocmask(SIG_SETMASK, &oldsignals, NULL);
		// casting discards const, but should be safe
		// (see http://stackoverflow.com/q/36925388)
		execvp(file, (char**) argv);
		fprintf(stderr, "can't execvp(\"%s\", ...): %s\n", file, strerror(errno));
		_exit(1);
	}
	else if (child < 0) {
		perror("Failed to fork()");
		return -1;
	}

	ret = sigtimedwait(&signals, &info, timeout);
	sigprocmask(SIG_SETMASK, &oldsignals, NULL);

	if (ret == SIGCHLD) {
		if (info.si_pid != child) {
			cleanup();
			error_message(1, 0,
				"BUG: We received a SIGCHLD from a child we didn't spawn (expected PID %d, got %d)",
				child, info.si_pid);
		}

		waitpid(child, NULL, 0);

		return info.si_status;
	}

	if (ret < 0 && errno == EAGAIN)
		error_message(0, 0, "warning: child %d took too long, killing", child);
	else if (ret < 0)
		warn_errno("sigtimedwait failed, killing child");
	else
		error_message(1, 0,
				"BUG: sigtimedwait() returned some other signal than SIGCHLD: %d",
				ret);

	kill(child, SIGKILL);
	kill(child, SIGCONT);
	waitpid(child, NULL, 0);
	return -1;
}

static void update_ebtables() {
	struct timespec timeout = {
		.tv_nsec = EBTABLES_TIMEOUT,
	};
	char mac[F_MAC_LEN + 1];
	struct router *router;

	if (G.best_router && G.best_router->tq >= G.max_tq - G.hysteresis_thresh) {
		DEBUG_MSG(F_MAC " is still good enough with TQ=%d (max_tq=%d), not executing ebtables",
			F_MAC_VAR(G.best_router->src),
			G.best_router->tq,
			G.max_tq);
		return;
	}

	foreach(router, G.routers) {
		if (router->tq == G.max_tq) {
			snprintf(mac, sizeof(mac), F_MAC, F_MAC_VAR(router->src));
			break;
		}
	}
	if (G.best_router)
		fprintf(stderr, "Switching from " F_MAC " (TQ=%d) to %s (TQ=%d)\n",
			F_MAC_VAR(G.best_router->src),
			G.best_router->tq,
			mac,
			G.max_tq);
	else
		fprintf(stderr, "Switching to %s (TQ=%d)\n",
			mac,
			G.max_tq);
	G.best_router = router;

	if (fork_execvp_timeout(&timeout, "ebtables", (const char *[])
			{ "ebtables", "-F", G.chain, NULL }))
		error_message(0, 0, "warning: flushing ebtables chain %s failed, not adding a new rule", G.chain);
	else if (fork_execvp_timeout(&timeout, "ebtables", (const char *[])
			{ "ebtables", "-A", G.chain, "-s", mac, "-j", "ACCEPT", NULL }))
		error_message(0, 0, "warning: adding new rule to ebtables chain %s failed", G.chain);
}

int main(int argc, char *argv[]) {
	int retval;
	fd_set rfds;
	struct timeval tv;
	time_t last_update = time(NULL);

	parse_cmdline(argc, argv);

	if (G.sock == 0)
		usage("No interface set!");

	if (G.chain == NULL)
		usage("No chain set!");

	while (1) {
		FD_ZERO(&rfds);
		FD_SET(G.sock, &rfds);

		tv.tv_sec = MAX_INTERVAL;
		tv.tv_usec = 0;
		retval = select(G.sock + 1, &rfds, NULL, NULL, &tv);

		if (retval < 0)
			exit_errno("select() failed");
		else if (retval) {
			if (FD_ISSET(G.sock, &rfds)) {
				handle_ra(G.sock);
			}
		}
		else
			DEBUG_MSG("select() timeout expired");

		if (G.routers != NULL && last_update <= time(NULL) - MIN_INTERVAL) {
			expire_routers();

			// all routers could have expired, check again
			if (G.routers != NULL) {
				update_tqs();
				update_ebtables();
				last_update = time(NULL);
			}
		}
	}

	cleanup();
	return 0;
}
