/*
 * Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
 *
 * Marek Lindner <mareklindner@neomailbox.ch>, Andrew Lunn <andrew@lunn.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of version 2 of the GNU General Public
 * License as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA
 *
 */

#include "batadv-netlink.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <net/ethernet.h>

#include "batman_adv.h"

#ifndef __maybe_unused
#define __maybe_unused __attribute__((unused))
#endif

struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
	[BATADV_ATTR_HARD_IFINDEX]	= { .type = NLA_U32 },
	[BATADV_ATTR_ORIG_ADDRESS]	= { .type = NLA_UNSPEC,
					    .minlen = ETH_ALEN,
					    .maxlen = ETH_ALEN },
	[BATADV_ATTR_FLAG_BEST]		= { .type = NLA_FLAG },
	[BATADV_ATTR_LAST_SEEN_MSECS]	= { .type = NLA_U32 },
	[BATADV_ATTR_NEIGH_ADDRESS]	= { .type = NLA_UNSPEC,
					    .minlen = ETH_ALEN,
					    .maxlen = ETH_ALEN },
	[BATADV_ATTR_TQ]		= { .type = NLA_U8 },
};

static int nlquery_error_cb(struct sockaddr_nl *nla __maybe_unused,
			    struct nlmsgerr *nlerr, void *arg)
{
	struct batadv_nlquery_opts *query_opts = arg;

	query_opts->err = nlerr->error;

	return NL_STOP;
}

static int nlquery_stop_cb(struct nl_msg *msg, void *arg)
{
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	int *error = nlmsg_data(nlh);

	if (*error)
		query_opts->err = *error;

	return NL_STOP;
}

int batadv_nl_query_common(const char *mesh_iface,
			   enum batadv_nl_commands nl_cmd,
			   nl_recvmsg_msg_cb_t callback, int flags,
			   struct batadv_nlquery_opts *query_opts)
{
	struct nl_sock *sock;
	struct nl_msg *msg;
	struct nl_cb *cb;
	int ifindex;
	int family;
	int ret;

	query_opts->err = 0;

	sock = nl_socket_alloc();
	if (!sock)
		return -ENOMEM;

	ret = genl_connect(sock);
	if (ret < 0) {
		query_opts->err = ret;
		goto err_free_sock;
	}

	family = genl_ctrl_resolve(sock, BATADV_NL_NAME);
	if (family < 0) {
		query_opts->err = -EOPNOTSUPP;
		goto err_free_sock;
	}

	ifindex = if_nametoindex(mesh_iface);
	if (!ifindex) {
		query_opts->err = -ENODEV;
		goto err_free_sock;
	}

	cb = nl_cb_alloc(NL_CB_DEFAULT);
	if (!cb) {
		query_opts->err = -ENOMEM;
		goto err_free_sock;
	}

	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, callback, query_opts);
	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, nlquery_stop_cb, query_opts);
	nl_cb_err(cb, NL_CB_CUSTOM, nlquery_error_cb, query_opts);

	msg = nlmsg_alloc();
	if (!msg) {
		query_opts->err = -ENOMEM;
		goto err_free_cb;
	}

	genlmsg_put(msg, NL_AUTO_PID, NL_AUTO_SEQ, family, 0, flags,
		    nl_cmd, 1);

	nla_put_u32(msg, BATADV_ATTR_MESH_IFINDEX, ifindex);
	nl_send_auto_complete(sock, msg);
	nlmsg_free(msg);

	nl_recvmsgs(sock, cb);

err_free_cb:
	nl_cb_put(cb);
err_free_sock:
	nl_socket_free(sock);

	return query_opts->err;
}
