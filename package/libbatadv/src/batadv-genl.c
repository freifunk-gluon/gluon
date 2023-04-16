// SPDX-License-Identifier: MIT
/* batman-adv helpers functions library
 *
 * Copyright (c) 2017, Sven Eckelmann <sven@narfation.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "batadv-genl.h"

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

__attribute__ ((visibility ("default")))
struct nla_policy batadv_genl_policy[NUM_BATADV_ATTR] = {
	[BATADV_ATTR_VERSION] = {
		.type = NLA_STRING,
	},
	[BATADV_ATTR_ALGO_NAME] = {
		.type = NLA_STRING,
	},
	[BATADV_ATTR_MESH_IFINDEX] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_MESH_IFNAME] = {
		.type = NLA_STRING,
		.maxlen = IFNAMSIZ,
	},
	[BATADV_ATTR_MESH_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_HARD_IFINDEX] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_HARD_IFNAME] = {
		.type = NLA_STRING,
		.maxlen = IFNAMSIZ,
	},
	[BATADV_ATTR_HARD_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_ORIG_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_TPMETER_RESULT] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_TPMETER_TEST_TIME] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_TPMETER_BYTES] = {
		.type = NLA_U64,
	},
	[BATADV_ATTR_TPMETER_COOKIE] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_PAD] = {
		.type = NLA_UNSPEC,
	},
	[BATADV_ATTR_ACTIVE] = {
		.type = NLA_FLAG,
	},
	[BATADV_ATTR_TT_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_TT_TTVN] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_TT_LAST_TTVN] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_TT_CRC32] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_TT_VID] = {
		.type = NLA_U16,
	},
	[BATADV_ATTR_TT_FLAGS] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_FLAG_BEST] = {
		.type = NLA_FLAG,
	},
	[BATADV_ATTR_LAST_SEEN_MSECS] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_NEIGH_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_TQ] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_THROUGHPUT] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_BANDWIDTH_UP] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_BANDWIDTH_DOWN] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_ROUTER] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_BLA_OWN] = {
		.type = NLA_FLAG,
	},
	[BATADV_ATTR_BLA_ADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_BLA_VID] = {
		.type = NLA_U16,
	},
	[BATADV_ATTR_BLA_BACKBONE] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_BLA_CRC] = {
		.type = NLA_U16,
	},
	[BATADV_ATTR_DAT_CACHE_IP4ADDRESS] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_DAT_CACHE_HWADDRESS] = {
		.type = NLA_UNSPEC,
		.minlen = ETH_ALEN,
		.maxlen = ETH_ALEN,
	},
	[BATADV_ATTR_DAT_CACHE_VID] = {
		.type = NLA_U16,
	},
	[BATADV_ATTR_MCAST_FLAGS] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_MCAST_FLAGS_PRIV] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_VLANID] = {
		.type = NLA_U16,
	},
	[BATADV_ATTR_AGGREGATED_OGMS_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_AP_ISOLATION_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_ISOLATION_MARK] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_ISOLATION_MASK] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_BONDING_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_BRIDGE_LOOP_AVOIDANCE_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_DISTRIBUTED_ARP_TABLE_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_FRAGMENTATION_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_GW_BANDWIDTH_DOWN] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_GW_BANDWIDTH_UP] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_GW_MODE] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_GW_SEL_CLASS] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_HOP_PENALTY] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_LOG_LEVEL] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_MULTICAST_FORCEFLOOD_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_NETWORK_CODING_ENABLED] = {
		.type = NLA_U8,
	},
	[BATADV_ATTR_ORIG_INTERVAL] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_ELP_INTERVAL] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_THROUGHPUT_OVERRIDE] = {
		.type = NLA_U32,
	},
	[BATADV_ATTR_MULTICAST_FANOUT] = {
		.type = NLA_U32,
	},
};

/**
 * nlquery_error_cb() - Store error value in &batadv_nlquery_opts->error and
 *  stop processing
 * @nla: netlink address of the peer
 * @nlerr: netlink error message being processed
 * @arg: &struct batadv_nlquery_opts given to batadv_genl_query()
 *
 * Return: Always NL_STOP
 */
static int nlquery_error_cb(struct sockaddr_nl *nla __attribute__((unused)),
		struct nlmsgerr *nlerr, void *arg)
{
	struct batadv_nlquery_opts *query_opts = arg;

	query_opts->err = nlerr->error;

	return NL_STOP;
}

/**
 * nlquery_stop_cb() - Store error value in &batadv_nlquery_opts->error and
 *  stop processing
 * @msg: netlink message being processed
 * @arg: &struct batadv_nlquery_opts given to batadv_genl_query()
 *
 * Return: Always NL_STOP
 */
static int nlquery_stop_cb(struct nl_msg *msg, void *arg)
{
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	int *error = nlmsg_data(nlh);

	if (*error)
		query_opts->err = *error;

	return NL_STOP;
}

/**
 * batadv_genl_query() - Start a common batman-adv generic netlink query
 * @mesh_iface: name of the batman-adv mesh interface
 * @nl_cmd: &enum batadv_nl_commands which should be sent to kernel
 * @callback: receive callback for valid messages
 * @flags: additional netlink message header flags
 * @query_opts: pointer to &struct batadv_nlquery_opts which is used to save
 *  the current processing state. This is given as arg to @callback
 *
 * Return: 0 on success or negative error value otherwise
 */
__attribute__ ((visibility ("default")))
int batadv_genl_query(const char *mesh_iface, enum batadv_nl_commands nl_cmd,
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
