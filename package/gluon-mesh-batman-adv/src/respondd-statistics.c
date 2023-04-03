/* SPDX-FileCopyrightText: 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */

#include "respondd-common.h"

#include <batadv-genl.h>

#include <json-c/json.h>

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <net/if.h>
#include <sys/types.h>
#include <sys/ioctl.h>

#include <linux/ethtool.h>
#include <linux/sockios.h>


#define MAX_INACTIVITY 60000


struct clients_netlink_opts {
	size_t clients;
	struct batadv_nlquery_opts query_opts;
};

struct gw_netlink_opts {
	struct json_object *obj;
	struct batadv_nlquery_opts query_opts;
};


static const enum batadv_nl_attrs gateways_mandatory[] = {
	BATADV_ATTR_ORIG_ADDRESS,
	BATADV_ATTR_ROUTER,
	BATADV_ATTR_TQ,
};

static int parse_gw_list_netlink_cb(struct nl_msg *msg, void *arg)
{
	struct nlattr *attrs[BATADV_ATTR_MAX+1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	struct genlmsghdr *ghdr;
	uint8_t *orig;
	uint8_t *router;
	uint8_t tq;
	struct gw_netlink_opts *opts;
	char addr[18];

	opts = batadv_container_of(query_opts, struct gw_netlink_opts,
			query_opts);

	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_GATEWAYS)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy))
		return NL_OK;

	if (batadv_genl_missing_attrs(attrs, gateways_mandatory,
				BATADV_ARRAY_SIZE(gateways_mandatory)))
		return NL_OK;

	if (!attrs[BATADV_ATTR_FLAG_BEST])
		return NL_OK;

	orig = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);
	router = nla_data(attrs[BATADV_ATTR_ROUTER]);
	tq = nla_get_u8(attrs[BATADV_ATTR_TQ]);

	sprintf(addr, "%02x:%02x:%02x:%02x:%02x:%02x",
		orig[0], orig[1], orig[2], orig[3], orig[4], orig[5]);

	json_object_object_add(opts->obj, "gateway", json_object_new_string(addr));
	json_object_object_add(opts->obj, "gateway_tq", json_object_new_int(tq));

	sprintf(addr, "%02x:%02x:%02x:%02x:%02x:%02x",
		router[0], router[1], router[2], router[3], router[4], router[5]);

	json_object_object_add(opts->obj, "gateway_nexthop", json_object_new_string(addr));

	return NL_STOP;
}

static void add_gateway(struct json_object *obj) {
	struct gw_netlink_opts opts = {
		.obj = obj,
		.query_opts = {
			.err = 0,
		},
	};

	batadv_genl_query("bat0", BATADV_CMD_GET_GATEWAYS,
			parse_gw_list_netlink_cb, NLM_F_DUMP,
			&opts.query_opts);
}

static inline bool ethtool_ioctl(int fd, struct ifreq *ifr, void *data) {
	ifr->ifr_data = data;

	return (ioctl(fd, SIOCETHTOOL, ifr) >= 0);
}

static uint32_t ethtool_get_stats_length(int fd, struct ifreq *ifr) {
	struct {
		struct ethtool_sset_info info;
		uint32_t buf;
	} sset = {};

	sset.info.cmd = ETHTOOL_GSSET_INFO;
	sset.info.sset_mask = (uint64_t)1 << ETH_SS_STATS;

	if (!ethtool_ioctl(fd, ifr, &sset.info))
		return 0;

	return sset.info.sset_mask ? sset.info.data[0] : 0;
}

static struct ethtool_gstrings * ethtool_get_stats_strings(int fd, struct ifreq *ifr) {
	uint32_t n_stats = ethtool_get_stats_length(fd, ifr);

	if (!n_stats)
		return NULL;

	struct ethtool_gstrings *strings = calloc(1, sizeof(*strings) + n_stats * ETH_GSTRING_LEN);

	strings->cmd = ETHTOOL_GSTRINGS;
	strings->string_set = ETH_SS_STATS;
	strings->len = n_stats;

	if (!ethtool_ioctl(fd, ifr, strings)) {
		free(strings);
		return NULL;
	}

	return strings;
}


static struct json_object * get_traffic(void) {
	struct ethtool_gstrings *strings = NULL;
	struct ethtool_stats *stats = NULL;

	struct ifreq ifr = {};
	strncpy(ifr.ifr_name, "bat0", IF_NAMESIZE);

	struct json_object *ret = NULL;

	int fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (fd < 0)
		return NULL;

	strings = ethtool_get_stats_strings(fd, &ifr);
	if (!strings)
		goto out;

	stats = calloc(1, sizeof(struct ethtool_stats) + strings->len * sizeof(uint64_t));
	stats->cmd = ETHTOOL_GSTATS;
	stats->n_stats = strings->len;

	if (!ethtool_ioctl(fd, &ifr, stats))
		goto out;

	struct json_object *rx = json_object_new_object();
	struct json_object *tx = json_object_new_object();
	struct json_object *forward = json_object_new_object();
	struct json_object *mgmt_rx = json_object_new_object();
	struct json_object *mgmt_tx = json_object_new_object();

	size_t i;
	for (i = 0; i < strings->len; i++) {
		if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "rx", ETH_GSTRING_LEN))
			json_object_object_add(rx, "packets", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "rx_bytes", ETH_GSTRING_LEN))
			json_object_object_add(rx, "bytes", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "tx", ETH_GSTRING_LEN))
			json_object_object_add(tx, "packets", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "tx_dropped", ETH_GSTRING_LEN))
			json_object_object_add(tx, "dropped", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "tx_bytes", ETH_GSTRING_LEN))
			json_object_object_add(tx, "bytes", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "forward", ETH_GSTRING_LEN))
			json_object_object_add(forward, "packets", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "forward_bytes", ETH_GSTRING_LEN))
			json_object_object_add(forward, "bytes", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "mgmt_rx", ETH_GSTRING_LEN))
			json_object_object_add(mgmt_rx, "packets", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "mgmt_rx_bytes", ETH_GSTRING_LEN))
			json_object_object_add(mgmt_rx, "bytes", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "mgmt_tx", ETH_GSTRING_LEN))
			json_object_object_add(mgmt_tx, "packets", json_object_new_int64(stats->data[i]));
		else if (!strncmp((const char*)&strings->data[i * ETH_GSTRING_LEN], "mgmt_tx_bytes", ETH_GSTRING_LEN))
			json_object_object_add(mgmt_tx, "bytes", json_object_new_int64(stats->data[i]));
	}

	ret = json_object_new_object();
	json_object_object_add(ret, "rx", rx);
	json_object_object_add(ret, "tx", tx);
	json_object_object_add(ret, "forward", forward);
	json_object_object_add(ret, "mgmt_rx", mgmt_rx);
	json_object_object_add(ret, "mgmt_tx", mgmt_tx);

out:
	free(stats);
	free(strings);
	close(fd);
	return ret;
}

static const enum batadv_nl_attrs clients_mandatory[] = {
	BATADV_ATTR_TT_FLAGS,
	/* Entries without the BATADV_TT_CLIENT_NOPURGE flag do not have a
	 * BATADV_ATTR_LAST_SEEN_MSECS attribute. We can still make this attr
	 * mandatory here, as entries without BATADV_TT_CLIENT_NOPURGE are
	 * ignored anyways.
	 */
	BATADV_ATTR_LAST_SEEN_MSECS,
};

static int parse_clients_list_netlink_cb(struct nl_msg *msg, void *arg)
{
	struct nlattr *attrs[BATADV_ATTR_MAX+1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	struct genlmsghdr *ghdr;
	struct clients_netlink_opts *opts;
	uint32_t flags, lastseen;

	opts = batadv_container_of(query_opts, struct clients_netlink_opts,
			query_opts);

	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_TRANSTABLE_LOCAL)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy))
		return NL_OK;

	if (batadv_genl_missing_attrs(attrs, clients_mandatory,
				BATADV_ARRAY_SIZE(clients_mandatory)))
		return NL_OK;

	flags = nla_get_u32(attrs[BATADV_ATTR_TT_FLAGS]);

	if (flags & (BATADV_TT_CLIENT_NOPURGE))
		return NL_OK;

	lastseen = nla_get_u32(attrs[BATADV_ATTR_LAST_SEEN_MSECS]);
	if (lastseen > MAX_INACTIVITY)
		return NL_OK;

	opts->clients++;

	return NL_OK;
}

static struct json_object * get_clients(void) {
	struct clients_netlink_opts opts = {
		.clients = 0,
		.query_opts = {
			.err = 0,
		},
	};

	batadv_genl_query("bat0", BATADV_CMD_GET_TRANSTABLE_LOCAL,
			parse_clients_list_netlink_cb, NLM_F_DUMP,
			&opts.query_opts);

	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "total", json_object_new_int(opts.clients));

	return ret;
}

struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "clients", get_clients());
	json_object_object_add(ret, "traffic", get_traffic());

	add_gateway(ret);

	return ret;
}
