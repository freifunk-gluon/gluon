/* SPDX-FileCopyrightText: 2016 Jan-Philipp Litza <janphilipp@litza.de> */
/* SPDX-FileCopyrightText: 2017 Sven Eckelmann <sven@narfation.org> */
/* SPDX-License-Identifier: BSD-2-Clause */

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

#include <net/ethernet.h>
#include <net/if.h>

#include <linux/filter.h>
#include <linux/if_packet.h>
#include <linux/limits.h>

#include <netinet/icmp6.h>
#include <netinet/in.h>
#include <netinet/ip6.h>

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <batadv-genl.h>

#include "mac.h"

// Recheck TQs after this time even if no RA was received
#define MAX_INTERVAL 60

// Recheck TQs at most this often, even if new RAs were received (they won't
// become the preferred routers until the TQs have been rechecked)
// Also, the first update will take at least this long
#define MIN_INTERVAL 15

// Remember the originator of a router for at most this period of time (in
// seconds). Re-read it from the transtable afterwards.
#define ORIGINATOR_CACHE_TTL 300

// max execution time of a single ebtables call in nanoseconds
#define EBTABLES_TIMEOUT 500000000 // 500ms

// TQ value assigned to local routers
#define LOCAL_TQ 512

#define BUFSIZE 1500

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
	for((item) = (list); (item) != NULL; (item) = (item)->next)

#define foreach_safe(item, safe, list) \
	for ((item) = (list); \
			(item) && (((safe) = item->next) || 1); \
			(item) = (safe))

struct router {
	struct router *next;
	struct ether_addr src;
	struct timespec eol;
	struct ether_addr originator;
	uint16_t tq;
};

static struct global {
	int sock;
	struct router *routers;
	const char *mesh_iface;
	const char *chain;
	uint16_t max_tq;
	uint16_t hysteresis_thresh;
	struct router *best_router;
	volatile sig_atomic_t stop_daemon;
} G = {
	.mesh_iface = "bat0",
};

static int fork_execvp_timeout(struct timespec *timeout, const char *file,
		const char *const argv[]);

static void error_message(int status, int errnum, char *message, ...) {
	va_list ap;
	va_start(ap, message);
	fflush(stdout);
	vfprintf(stderr, message, ap);
	va_end(ap);

	if (errnum)
		fprintf(stderr, ": %s", strerror(errnum));
	fprintf(stderr, "\n");
	if (status)
		exit(status);
}

static int timespec_diff(struct timespec *tv1, struct timespec *tv2,
		struct timespec *tvdiff)
{
	tvdiff->tv_sec = tv1->tv_sec - tv2->tv_sec;
	if (tv1->tv_nsec < tv2->tv_nsec) {
		tvdiff->tv_nsec = 1000000000 + tv1->tv_nsec - tv2->tv_nsec;
		tvdiff->tv_sec -= 1;
	} else {
		tvdiff->tv_nsec = tv1->tv_nsec - tv2->tv_nsec;
	}

	return (tvdiff->tv_sec >= 0);
}

static void cleanup(void) {
	struct router *router;
	struct timespec timeout = {
		.tv_nsec = EBTABLES_TIMEOUT,
	};

	close(G.sock);

	while (G.routers != NULL) {
		router = G.routers;
		G.routers = router->next;
		free(router);
	}

	if (G.chain) {
		/* Reset chain to accept everything again */
		if (fork_execvp_timeout(&timeout, "ebtables", (const char *[])
				{ "ebtables", "-F", G.chain, NULL }))
			DEBUG_MSG("warning: flushing ebtables chain %s failed, not adding a new rule", G.chain);

		if (fork_execvp_timeout(&timeout, "ebtables", (const char *[])
				{ "ebtables", "-A", G.chain, "-j", "ACCEPT", NULL }))
			DEBUG_MSG("warning: adding new rule to ebtables chain %s failed", G.chain);
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
	ret = bind(sock, (struct sockaddr *)&bind_iface, sizeof(bind_iface));
	if (ret < 0)
		exit_errno("can't bind socket");

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
				if (G.sock >= 0)
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

static struct router *router_find_src(const struct ether_addr *src) {
	struct router *router;

	foreach(router, G.routers) {
		if (ether_addr_equal(router->src, *src))
			return router;
	}

	return NULL;
}

static struct router *router_find_orig(const struct ether_addr *orig) {
	struct router *router;

	foreach(router, G.routers) {
		if (ether_addr_equal(router->originator, *orig))
			return router;
	}

	return NULL;
}

static struct router *router_add(const struct ether_addr *mac) {
	struct router *router;

	router = malloc(sizeof(*router));
	if (!router)
		return NULL;

	router->src = *mac;
	router->next = G.routers;
	G.routers = router;
	router->eol.tv_sec = 0;
	router->eol.tv_nsec = 0;
	memset(&router->originator, 0, sizeof(router->originator));

	return router;
}

static void router_update(const struct ether_addr *mac, uint16_t timeout) {
	struct router *router;

	router = router_find_src(mac);
	if (!router)
		router = router_add(mac);
	if (!router)
		return;

	clock_gettime(CLOCK_MONOTONIC, &router->eol);
	router->eol.tv_sec += timeout;
}

static void handle_ra(int sock) {
	struct sockaddr_ll src;
	struct ether_addr mac;
	socklen_t addr_size = sizeof(src);
	ssize_t len;
	struct {
		struct ip6_hdr ip6;
		struct nd_router_advert ra;
	} pkt;

	len = recvfrom(sock, &pkt, sizeof(pkt), 0, (struct sockaddr *)&src, &addr_size);
	CHECK(len >= 0);

	// BPF already checked that this is an ICMPv6 RA of a default router
	CHECK((size_t)len >= sizeof(pkt));
	CHECK(ntohs(pkt.ip6.ip6_plen) + sizeof(struct ip6_hdr) >= sizeof(pkt));

	memcpy(&mac, src.sll_addr, sizeof(mac));
	DEBUG_MSG("received valid RA from " F_MAC, F_MAC_VAR(mac));

	router_update(&mac, ntohs(pkt.ra.nd_ra_router_lifetime));

check_failed:
	return;
}

static void expire_routers(void) {
	struct router **prev_ptr = &G.routers;
	struct router *router;
	struct router *safe;
	struct timespec now;
	struct timespec diff;

	clock_gettime(CLOCK_MONOTONIC, &now);

	foreach_safe(router, safe, G.routers) {
		if (timespec_diff(&now, &router->eol, &diff)) {
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

static int parse_tt_global(struct nl_msg *msg,
		void *arg __attribute__((unused)))
{
	static const enum batadv_nl_attrs mandatory[] = {
		BATADV_ATTR_TT_ADDRESS,
		BATADV_ATTR_ORIG_ADDRESS,
	};
	struct nlattr *attrs[BATADV_ATTR_MAX + 1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct ether_addr mac_a, mac_b;
	struct genlmsghdr *ghdr;
	struct router *router;
	uint8_t *addr;
	uint8_t *orig;

	// parse netlink entry
	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_TRANSTABLE_GLOBAL)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy)) {
		return NL_OK;
	}

	if (batadv_genl_missing_attrs(attrs, mandatory, ARRAY_SIZE(mandatory)))
		return NL_OK;

	addr = nla_data(attrs[BATADV_ATTR_TT_ADDRESS]);
	orig = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);

	if (!attrs[BATADV_ATTR_FLAG_BEST])
		return NL_OK;

	MAC2ETHER(mac_a, addr);
	MAC2ETHER(mac_b, orig);

	// update router
	router = router_find_src(&mac_a);
	if (!router)
		return NL_OK;

	DEBUG_MSG("Found originator for " F_MAC ", it's " F_MAC,
			F_MAC_VAR(router->src), F_MAC_VAR(mac_b));
	router->originator = mac_b;

	return NL_OK;
}

static int parse_originator(struct nl_msg *msg,
		void *arg __attribute__((unused)))
{

	static const enum batadv_nl_attrs mandatory[] = {
		BATADV_ATTR_ORIG_ADDRESS,
		BATADV_ATTR_TQ,
	};
	struct nlattr *attrs[BATADV_ATTR_MAX + 1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct ether_addr mac_a;
	struct genlmsghdr *ghdr;
	struct router *router;
	uint8_t *orig;
	uint8_t tq;

	// parse netlink entry
	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_ORIGINATORS)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy)) {
		return NL_OK;
	}

	if (batadv_genl_missing_attrs(attrs, mandatory, ARRAY_SIZE(mandatory)))
		return NL_OK;

	orig = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);
	tq = nla_get_u8(attrs[BATADV_ATTR_TQ]);

	if (!attrs[BATADV_ATTR_FLAG_BEST])
		return NL_OK;

	MAC2ETHER(mac_a, orig);

	// update router
	router = router_find_orig(&mac_a);
	if (!router)
		return NL_OK;

	DEBUG_MSG("Found TQ for router " F_MAC " (originator " F_MAC "), it's %d",
			F_MAC_VAR(router->src), F_MAC_VAR(router->originator), tq);
	router->tq = tq;
	if (router->tq > G.max_tq)
		G.max_tq = router->tq;

	return NL_OK;
}

static int parse_tt_local(struct nl_msg *msg,
		void *arg __attribute__((unused)))
{
	static const enum batadv_nl_attrs mandatory[] = {
		BATADV_ATTR_TT_ADDRESS,
	};
	struct nlattr *attrs[BATADV_ATTR_MAX + 1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct ether_addr mac_a;
	struct genlmsghdr *ghdr;
	struct router *router;
	uint8_t *addr;

	// parse netlink entry
	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_TRANSTABLE_LOCAL)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy)) {
		return NL_OK;
	}

	if (batadv_genl_missing_attrs(attrs, mandatory, ARRAY_SIZE(mandatory)))
		return NL_OK;

	addr = nla_data(attrs[BATADV_ATTR_TT_ADDRESS]);
	MAC2ETHER(mac_a, addr);

	// update router
	router = router_find_src(&mac_a);
	if (!router)
		return NL_OK;

	DEBUG_MSG("Found router " F_MAC " in transtable_local, assigning TQ %d",
			F_MAC_VAR(router->src), LOCAL_TQ);
	router->tq = LOCAL_TQ;
	if (router->tq > G.max_tq)
		G.max_tq = router->tq;

	return NL_OK;
}

static void update_tqs(void) {
	static const struct ether_addr unspec = {};
	struct router *router;
	bool update_originators = false;
	struct batadv_nlquery_opts opts;
	int ret;

	// reset TQs
	foreach(router, G.routers) {
		router->tq = 0;
		if (ether_addr_equal(router->originator, unspec))
			update_originators = true;
	}

	// translate all router's MAC addresses to originators simultaneously
	if (update_originators) {
		opts.err = 0;
		ret = batadv_genl_query(G.mesh_iface,
					BATADV_CMD_GET_TRANSTABLE_GLOBAL,
					parse_tt_global, NLM_F_DUMP, &opts);
		if (ret < 0)
			fprintf(stderr, "Parsing of global translation table failed\n");
	}

	// look up TQs of originators
	G.max_tq = 0;
	opts.err = 0;
	ret = batadv_genl_query(G.mesh_iface,
				BATADV_CMD_GET_ORIGINATORS,
				parse_originator, NLM_F_DUMP, &opts);
	if (ret < 0)
		fprintf(stderr, "Parsing of originators failed\n");

	// if all routers have a TQ value, we don't need to check translocal
	foreach(router, G.routers) {
		if (router->tq == 0)
			break;
	}
	if (router != NULL) {
		opts.err = 0;
		ret = batadv_genl_query(G.mesh_iface,
					BATADV_CMD_GET_TRANSTABLE_LOCAL,
					parse_tt_local, NLM_F_DUMP, &opts);
		if (ret < 0)
			fprintf(stderr, "Parsing of global translation table failed\n");
	}

	foreach(router, G.routers) {
		if (router->tq == 0) {
			if (ether_addr_equal(router->originator, unspec))
				DEBUG_MSG(
					"Unable to find router " F_MAC " in transtable_{global,local}",
					F_MAC_VAR(router->src));
			else
				DEBUG_MSG(
					"Unable to find TQ for originator " F_MAC " (router " F_MAC ")",
					F_MAC_VAR(router->originator),
					F_MAC_VAR(router->src));
		}
	}
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
		// (see https://stackoverflow.com/q/36925388)
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

static bool election_required(void)
{
	if (!G.best_router)
		return true;

	/* should never happen. G.max_tq also contains G.best_router->tq */
	if (G.max_tq < G.best_router->tq)
		return false;

	if ((G.max_tq - G.best_router->tq) <= G.hysteresis_thresh)
		return false;

	return true;
}

static void update_ebtables(void) {
	struct timespec timeout = {
		.tv_nsec = EBTABLES_TIMEOUT,
	};
	char mac[F_MAC_LEN + 1];
	struct router *router;

	if (!election_required()) {
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

static void invalidate_originators(void)
{
	struct router *router;
	foreach(router, G.routers) {
		memset(&router->originator, 0, sizeof(router->originator));
	}
}

static void sighandler(int sig __attribute__((unused)))
{
	G.stop_daemon = 1;
}

int main(int argc, char *argv[]) {
	int retval;
	fd_set rfds;
	struct timeval tv;
	struct timespec next_update;
	struct timespec next_invalidation;
	struct timespec now;
	struct timespec diff;

	clock_gettime(CLOCK_MONOTONIC, &next_update);
	next_update.tv_sec += MIN_INTERVAL;

	clock_gettime(CLOCK_MONOTONIC, &next_invalidation);
	next_invalidation.tv_sec += MIN_INTERVAL;

	G.sock = -1;
	parse_cmdline(argc, argv);

	if (G.sock < 0)
		usage("No interface set!");

	if (G.chain == NULL)
		usage("No chain set!");

	G.stop_daemon = 0;
	signal(SIGINT, sighandler);
	signal(SIGTERM, sighandler);

	while (!G.stop_daemon) {
		FD_ZERO(&rfds);
		FD_SET(G.sock, &rfds);

		tv.tv_sec = MAX_INTERVAL;
		tv.tv_usec = 0;
		retval = select(G.sock + 1, &rfds, NULL, NULL, &tv);

		if (retval < 0) {
			if (errno != EINTR)
				exit_errno("select() failed");
		} else if (retval) {
			if (FD_ISSET(G.sock, &rfds)) {
				handle_ra(G.sock);
			}
		}
		else
			DEBUG_MSG("select() timeout expired");

		clock_gettime(CLOCK_MONOTONIC, &now);
		if (G.routers != NULL &&
				timespec_diff(&now, &next_update, &diff)) {
			expire_routers();

			// all routers could have expired, check again
			if (G.routers != NULL) {
				if(timespec_diff(&now, &next_invalidation, &diff)) {
					invalidate_originators();

					next_invalidation = now;
					next_invalidation.tv_sec += ORIGINATOR_CACHE_TTL;
				}

				update_tqs();
				update_ebtables();

				next_update = now;
				next_update.tv_sec += MIN_INTERVAL;
			}
		}
	}

	cleanup();
	return 0;
}
