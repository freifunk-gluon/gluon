/*
  Copyright (c) 2014, Matthias Schiffer <mschiffer@universe-factory.net>
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
#include <error.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <arpa/inet.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <net/if.h>

#include <linux/if_ether.h>
#include <linux/pkt_cls.h>
#include <linux/pkt_sched.h>
#include <linux/rtnetlink.h>


#include <netlink/msg.h>
#include <netlink/attr.h>
#include <netlink/socket.h>


static struct nl_cb *cb;
static struct nl_sock *sock;
static double ticks;

static unsigned ifindex;

static bool nlexpect;
static int nlerror;


static inline void exit_errno(const char *message) {
	error(1, errno, "error: %s", message);
}

static inline void warn_errno(const char *message) {
	error(0, errno, "warning: %s", message);
}


static void read_psched(void) {
	uint32_t clock_res;
	uint32_t t2us;
	uint32_t us2t;

	FILE *f = fopen("/proc/net/psched", "r");
	if (!f || fscanf(f, "%08x %08x %08x", &t2us, &us2t, &clock_res) != 3)
		exit_errno("error reading /proc/net/psched");
	fclose(f);

	/* compatibility hack from iproute... */
	if (clock_res == 1000000000)
		t2us = us2t;

	ticks = (double)t2us / us2t * clock_res;
}


static struct nl_msg * prepare_tcmsg(int type, int flags, uint32_t parent, uint32_t handle, uint32_t info) {
	struct nl_msg *msg = nlmsg_alloc_simple(type, flags);
	if (!msg)
		exit_errno("nlmsg_alloc_simple");

	struct tcmsg tcmsg;
	memset(&tcmsg, 0, sizeof(tcmsg));

	tcmsg.tcm_family = AF_UNSPEC;
	tcmsg.tcm_ifindex = ifindex;
	tcmsg.tcm_parent = parent;
	tcmsg.tcm_handle = handle;
	tcmsg.tcm_info = info;

	nlmsg_append(msg, &tcmsg, sizeof(tcmsg), NLMSG_ALIGNTO);

	return msg;
}


static int error_handler(struct sockaddr_nl *nla __attribute__((unused)), struct nlmsgerr *nlerr, void *arg __attribute__((unused))) {
	if (!nlexpect || (nlerr->error != -ENOENT && nlerr->error != -EINVAL))
		nlerror = -nlerr->error;

	return NL_STOP;
}

static bool do_send(struct nl_msg *msg, bool expect) {
	nlerror = 0;
	nlexpect = expect;

	nl_send_auto_complete(sock, msg);
	nlmsg_free(msg);
	nl_wait_for_ack(sock);

	if (nlerror) {
		error(0, nlerror, "netlink");
		errno = nlerror;
		return false;
	}

	return true;
}


static inline unsigned get_xmittime(double rate, unsigned size) {
	return ticks * (size/rate);
}


static void complete_rate(struct tc_ratespec *r, uint32_t rtab[256]) {
	r->linklayer = TC_LINKLAYER_ETHERNET;
	r->cell_align = -1;
	r->cell_log = 3;

	unsigned i;
	for (i = 0; i < 256; i++)
		rtab[i] = get_xmittime(r->rate, (i + 1) << 3);
}


static void do_ingress(double rate) {
	if (!do_send(prepare_tcmsg(RTM_DELQDISC, 0, TC_H_INGRESS, 0xffff0000, 0), true))
		return;

	if (rate < 0)
		return;


	struct nl_msg *msg = prepare_tcmsg(RTM_NEWQDISC, NLM_F_CREATE | NLM_F_EXCL, TC_H_INGRESS, 0xffff0000, 0);
	nla_put_string(msg, TCA_KIND, "ingress");

	if (!do_send(msg, false))
		return;


	msg = prepare_tcmsg(RTM_NEWTFILTER, NLM_F_CREATE | NLM_F_EXCL, 0xffff0000, 0, TC_H_MAKE(0, htons(ETH_P_ALL)));

	const unsigned buffer = 10240;

	struct tc_police p;
	memset(&p, 0, sizeof(p));

	/* Range check has been done in main() */
	p.rate.rate = rate;
	p.burst = get_xmittime(p.rate.rate, buffer);
	p.action = TC_POLICE_SHOT;

	uint32_t rtab[256];
	complete_rate(&p.rate, rtab);

	nla_put_string(msg, TCA_KIND, "basic");

	struct nlattr *opts = nla_nest_start(msg, TCA_OPTIONS);
	struct nlattr *police = nla_nest_start(msg, TCA_BASIC_POLICE);

	nla_put(msg, TCA_POLICE_TBF, sizeof(p), &p);
	nla_put(msg, TCA_POLICE_RATE, sizeof(rtab), rtab);

	nla_nest_end(msg, police);
	nla_nest_end(msg, opts);

	do_send(msg, false);
}

static void do_egress(double rate) {
	if (!do_send(prepare_tcmsg(RTM_DELQDISC, 0, TC_H_ROOT, 0, 0), true))
		return;

	if (rate < 0)
		return;


	struct nl_msg *msg = prepare_tcmsg(RTM_NEWQDISC, NLM_F_CREATE | NLM_F_EXCL, TC_H_ROOT, 0, 0);
	const unsigned buffer = 2048;

	struct tc_tbf_qopt opt;
	memset(&opt, 0, sizeof(opt));

	/* Range check has been done in main() */
	opt.rate.rate = rate;
	opt.limit = 0.05*rate + buffer;
	opt.buffer = get_xmittime(opt.rate.rate, buffer);

	uint32_t rtab[256];
	complete_rate(&opt.rate, rtab);

	nla_put_string(msg, TCA_KIND, "tbf");

	struct nlattr *opts = nla_nest_start(msg, TCA_OPTIONS);
	nla_put(msg, TCA_TBF_PARMS, sizeof(opt), &opt);
	nla_put(msg, TCA_TBF_BURST, sizeof(buffer), &buffer);
	nla_put(msg, TCA_TBF_RTAB, sizeof(rtab), rtab);
	nla_nest_end(msg, opts);

	do_send(msg, false);
}


static inline void usage(void) {
	fprintf(stderr, "Usage: gluon-simple-tc <interface> <ingress Kbit/s>|- <egress Kbit/s>|-\n");
	exit(1);
}

static inline void maxrate(void) {
	error(1, 0, "error: maximum allowed rate it about 2^25 Kbit/s");
}


int main(int argc, char *argv[]) {
	if (argc != 4)
		usage();

	double ingress = -1, egress = -1;
	char *end;

	ifindex = if_nametoindex(argv[1]);
	if (!ifindex)
		error(1, 0, "invalid interface: %s", argv[1]);

	if (strcmp(argv[2], "-") != 0) {
		ingress = strtod(argv[2], &end);
		if (*end || ingress < 0)
			usage();

		ingress *= 125;

		if (ingress >= (1ull << 32))
			maxrate();
	}

	if (strcmp(argv[3], "-") != 0) {
		egress = strtod(argv[3], &end);
		if (*end || egress < 0)
			usage();

		egress *= 125;

		if (egress >= (1ull << 32))
			maxrate();
	}

	read_psched();

	cb = nl_cb_alloc(NL_CB_DEFAULT);
	nl_cb_err(cb, NL_CB_CUSTOM, error_handler, NULL);

	sock = nl_socket_alloc_cb(cb);
	if (!sock)
		exit_errno("nl_socket_alloc");

	if (nl_connect(sock, NETLINK_ROUTE))
		exit_errno("nl_connect");

	do_ingress(ingress);
	do_egress(egress);

	nl_socket_free(sock);
	nl_cb_put(cb);

	return 0;
}
