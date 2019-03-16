/*
  Copyright (c) 2016, Matthias Schiffer <mschiffer@universe-factory.net>
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


#include <respondd.h>

#include <ifaddrs.h>
#include <iwinfo.h>
#include <json-c/json.h>
#include <libgluonutil.h>
#include <uci.h>

#include <alloca.h>
#include <glob.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/in.h>

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include <linux/ethtool.h>
#include <linux/if_addr.h>
#include <linux/rtnetlink.h>
#include <linux/sockios.h>

#include <batadv-genl.h>


#define _STRINGIFY(s) #s
#define STRINGIFY(s) _STRINGIFY(s)

#define MAX_INACTIVITY 60000


struct neigh_netlink_opts {
	struct json_object *interfaces;
	struct batadv_nlquery_opts query_opts;
};

struct gw_netlink_opts {
	struct json_object *obj;
	struct batadv_nlquery_opts query_opts;
};

struct clients_netlink_opts {
	size_t non_wifi;
	struct batadv_nlquery_opts query_opts;
};

struct ip_address_information {
	unsigned int ifindex;
	struct json_object *addresses;
};

static int get_addresses_cb(struct nl_msg *msg, void *arg) {
	struct ip_address_information *info = (struct ip_address_information*) arg;

	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct ifaddrmsg *msg_content = NLMSG_DATA(nlh);
	int remaining = nlh->nlmsg_len - NLMSG_LENGTH(sizeof(struct ifaddrmsg));
	struct rtattr *hdr;

	for (hdr = IFA_RTA(msg_content); RTA_OK(hdr, remaining); hdr = RTA_NEXT(hdr, remaining)) {
		char addr_str_buf[INET6_ADDRSTRLEN];

		/* We are only interested in IP-addresses of br-client */
		if (hdr->rta_type != IFA_ADDRESS ||
			msg_content->ifa_index != info->ifindex ||
			msg_content->ifa_flags & (IFA_F_TENTATIVE|IFA_F_DEPRECATED)) {
			continue;
		}

		if (inet_ntop(AF_INET6, (struct in6_addr *) RTA_DATA(hdr), addr_str_buf, INET6_ADDRSTRLEN)) {
			json_object_array_add(info->addresses, json_object_new_string(addr_str_buf));
		}
	}

	return NL_OK;
}

static struct json_object *get_addresses(void) {
	struct ip_address_information info = {
		.ifindex = if_nametoindex("br-client"),
		.addresses = json_object_new_array(),
	};
	int err;

	/* Open socket */
	struct nl_sock *socket = nl_socket_alloc();
	if (!socket) {
		return info.addresses;
	}

	err = nl_connect(socket, NETLINK_ROUTE);
	if (err < 0) {
		goto out_free;
	}

	/* Send message */
	struct ifaddrmsg rt_hdr = { .ifa_family = AF_INET6, };
	err = nl_send_simple(socket, RTM_GETADDR, NLM_F_REQUEST | NLM_F_ROOT, &rt_hdr, sizeof(struct ifaddrmsg));
	if (err < 0) {
		goto out_free;
	}

	/* Retrieve answer. Message is handled by get_addresses_cb */
	nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM, get_addresses_cb, &info);
	nl_recvmsgs_default(socket);

out_free:
	nl_socket_free(socket);
	return info.addresses;
}

static void add_if_not_empty(struct json_object *obj, const char *key, struct json_object *val) {
	if (json_object_array_length(val))
		json_object_object_add(obj, key, val);
	else
		json_object_put(val);
}

static bool interface_file_exists(const char *ifname, const char *name) {
	const char *format = "/sys/class/net/%s/%s";
	char path[strlen(format) + strlen(ifname) + strlen(name)];
	snprintf(path, sizeof(path), format, ifname, name);

	return !access(path, F_OK);
}

static void mesh_add_subif(const char *ifname, struct json_object *wireless,
			   struct json_object *tunnel, struct json_object *other) {
	struct json_object *address = gluonutil_wrap_and_free_string(gluonutil_get_interface_address(ifname));

	char lowername[IFNAMSIZ];
	strncpy(lowername, ifname, sizeof(lowername)-1);
	lowername[sizeof(lowername)-1] = 0;

	const char *format = "/sys/class/net/%s/lower_*";
	char pattern[strlen(format) + IFNAMSIZ];

	/* In case of VLAN and bridge interfaces, we want the lower interface
	 * to determine the interface type (but not for the interface address) */
	while (true) {
		snprintf(pattern, sizeof(pattern), format, lowername);
		size_t pattern_len = strlen(pattern);

		glob_t lower;
		if (glob(pattern, GLOB_NOSORT, NULL, &lower))
			break;

		strncpy(lowername, lower.gl_pathv[0] + pattern_len - 1, sizeof(lowername)-1);

		globfree(&lower);
	}

	if (interface_file_exists(lowername, "wireless"))
		json_object_array_add(wireless, address);
	else if (interface_file_exists(lowername, "tun_flags"))
		json_object_array_add(tunnel, address);
	else
		json_object_array_add(other, address);

}

static struct json_object * get_mesh_subifs(const char *ifname) {
	struct json_object *wireless = json_object_new_array();
	struct json_object *tunnel = json_object_new_array();
	struct json_object *other = json_object_new_array();

	const char *format = "/sys/class/net/%s/lower_*";
	char pattern[strlen(format) + strlen(ifname) - 1];
	snprintf(pattern, sizeof(pattern), format, ifname);

	size_t pattern_len = strlen(pattern);

	glob_t lower;
	if (!glob(pattern, GLOB_NOSORT, NULL, &lower)) {
		size_t i;
		for (i = 0; i < lower.gl_pathc; i++) {
			mesh_add_subif(lower.gl_pathv[i] + pattern_len - 1,
				       wireless, tunnel, other);
		}

		globfree(&lower);
	}

	struct json_object *ret = json_object_new_object();
	add_if_not_empty(ret, "wireless", wireless);
	add_if_not_empty(ret, "tunnel", tunnel);
	add_if_not_empty(ret, "other", other);
	return ret;
}

static struct json_object * get_mesh(void) {
	struct json_object *ret = json_object_new_object();
	struct json_object *bat0_interfaces = json_object_new_object();
	json_object_object_add(bat0_interfaces, "interfaces", get_mesh_subifs("bat0"));
	json_object_object_add(ret, "bat0", bat0_interfaces);
	return ret;
}

static struct json_object * get_batman_adv_compat(void) {
	FILE *f = fopen("/lib/gluon/mesh-batman-adv/compat", "r");
	if (!f)
		return NULL;

	struct json_object *ret = NULL;

	int compat;
	if (fscanf(f, "%i", &compat) == 1)
		ret = json_object_new_int(compat);

	fclose(f);

	return ret;
}

static struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *network = json_object_new_object();
	json_object_object_add(network, "addresses", get_addresses());
	json_object_object_add(network, "mesh", get_mesh());
	json_object_object_add(ret, "network", network);

	struct json_object *software = json_object_new_object();
	struct json_object *software_batman_adv = json_object_new_object();
	json_object_object_add(software_batman_adv, "version", gluonutil_wrap_and_free_string(gluonutil_read_line("/sys/module/batman_adv/version")));
	json_object_object_add(software_batman_adv, "compat", get_batman_adv_compat());
	json_object_object_add(software, "batman-adv", software_batman_adv);
	json_object_object_add(ret, "software", software);

	return ret;
}

static const enum batadv_nl_attrs gateways_mandatory[] = {
	BATADV_ATTR_ORIG_ADDRESS,
	BATADV_ATTR_ROUTER,
};

static int parse_gw_list_netlink_cb(struct nl_msg *msg, void *arg)
{
	struct nlattr *attrs[BATADV_ATTR_MAX+1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	struct genlmsghdr *ghdr;
	uint8_t *orig;
	uint8_t *router;
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

	sprintf(addr, "%02x:%02x:%02x:%02x:%02x:%02x",
		orig[0], orig[1], orig[2], orig[3], orig[4], orig[5]);

	json_object_object_add(opts->obj, "gateway", json_object_new_string(addr));

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
	const size_t sset_info_len = sizeof(struct ethtool_sset_info) + sizeof(uint32_t);
	struct ethtool_sset_info *sset_info = alloca(sset_info_len);
	memset(sset_info, 0, sset_info_len);

	sset_info->cmd = ETHTOOL_GSSET_INFO;
	sset_info->sset_mask = 1ull << ETH_SS_STATS;

	if (!ethtool_ioctl(fd, ifr, sset_info))
		return 0;

	return sset_info->sset_mask ? sset_info->data[0] : 0;
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

static void count_iface_stations(size_t *wifi24, size_t *wifi5, const char *ifname) {
	const struct iwinfo_ops *iw = iwinfo_backend(ifname);
	if (!iw)
		return;

	int freq;
	if (iw->frequency(ifname, &freq) < 0)
		return;

	size_t *wifi;
	if (freq >= 2400 && freq < 2500)
		wifi = wifi24;
	else if (freq >= 5000 && freq < 6000)
		wifi = wifi5;
	else
		return;

	int len;
	char buf[IWINFO_BUFSIZE];
	if (iw->assoclist(ifname, buf, &len) < 0)
		return;

	struct iwinfo_assoclist_entry *entry;
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++) {
		if (entry->inactive > MAX_INACTIVITY)
			continue;

		(*wifi)++;
	}
}

static void count_stations(size_t *wifi24, size_t *wifi5) {
	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		return;
	ctx->flags &= ~UCI_FLAG_STRICT;


	struct uci_package *p;
	if (uci_load(ctx, "wireless", &p))
		goto end;


	struct uci_element *e;
	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);
		if (strcmp(s->type, "wifi-iface"))
			continue;

		const char *network = uci_lookup_option_string(ctx, s, "network");
		if (!network || strcmp(network, "client"))
			continue;

		const char *mode = uci_lookup_option_string(ctx, s, "mode");
		if (!mode || strcmp(mode, "ap"))
			continue;

		const char *ifname = uci_lookup_option_string(ctx, s, "ifname");
		if (!ifname)
			continue;

		count_iface_stations(wifi24, wifi5, ifname);
	}

 end:
	uci_free_context(ctx);
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

	if (flags & (BATADV_TT_CLIENT_NOPURGE | BATADV_TT_CLIENT_WIFI))
		return NL_OK;

	lastseen = nla_get_u32(attrs[BATADV_ATTR_LAST_SEEN_MSECS]);
	if (lastseen > MAX_INACTIVITY)
		return NL_OK;

	opts->non_wifi++;

	return NL_OK;
}

static struct json_object * get_clients(void) {
	size_t wifi24 = 0, wifi5 = 0;
	size_t total;
	size_t wifi;
	struct clients_netlink_opts opts = {
		.non_wifi = 0,
		.query_opts = {
			.err = 0,
		},
	};

	batadv_genl_query("bat0", BATADV_CMD_GET_TRANSTABLE_LOCAL,
			  parse_clients_list_netlink_cb, NLM_F_DUMP,
			  &opts.query_opts);

	count_stations(&wifi24, &wifi5);
	wifi = wifi24 + wifi5;
	total = wifi + opts.non_wifi;

	struct json_object *ret = json_object_new_object();
	json_object_object_add(ret, "total", json_object_new_int(total));
	json_object_object_add(ret, "wifi", json_object_new_int(wifi));
	json_object_object_add(ret, "wifi24", json_object_new_int(wifi24));
	json_object_object_add(ret, "wifi5", json_object_new_int(wifi5));
	return ret;
}


static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "clients", get_clients());
	json_object_object_add(ret, "traffic", get_traffic());

	add_gateway(ret);

	return ret;
}


static struct json_object * ifnames2addrs(struct json_object *interfaces) {
	struct json_object *ret = json_object_new_object();

	json_object_object_foreach(interfaces, ifname, interface) {
		char *ifaddr = gluonutil_get_interface_address(ifname);
		if (!ifaddr)
			continue;

		struct json_object *obj = json_object_new_object();
		json_object_object_add(obj, "neighbours", json_object_get(interface));
		json_object_object_add(ret, ifaddr, obj);

		free(ifaddr);
	}

	json_object_put(interfaces);

	return ret;
}

static const enum batadv_nl_attrs parse_orig_list_mandatory[] = {
	BATADV_ATTR_ORIG_ADDRESS,
	BATADV_ATTR_NEIGH_ADDRESS,
	BATADV_ATTR_TQ,
	BATADV_ATTR_HARD_IFINDEX,
	BATADV_ATTR_LAST_SEEN_MSECS,
};

static int parse_orig_list_netlink_cb(struct nl_msg *msg, void *arg)
{
	struct nlattr *attrs[BATADV_ATTR_MAX+1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	struct genlmsghdr *ghdr;
	uint8_t *orig;
	uint8_t *dest;
	uint8_t tq;
	uint32_t hardif;
	uint32_t lastseen;
	char ifname_buf[IF_NAMESIZE], *ifname;
	struct neigh_netlink_opts *opts;
	char mac1[18];

	opts = batadv_container_of(query_opts, struct neigh_netlink_opts,
				   query_opts);

	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (ghdr->cmd != BATADV_CMD_GET_ORIGINATORS)
		return NL_OK;

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
		      genlmsg_len(ghdr), batadv_genl_policy))
		return NL_OK;

	if (batadv_genl_missing_attrs(attrs, parse_orig_list_mandatory,
				      BATADV_ARRAY_SIZE(parse_orig_list_mandatory)))
		return NL_OK;

	if (!attrs[BATADV_ATTR_FLAG_BEST])
		return NL_OK;

	orig = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);
	dest = nla_data(attrs[BATADV_ATTR_NEIGH_ADDRESS]);
	tq = nla_get_u8(attrs[BATADV_ATTR_TQ]);
	hardif = nla_get_u32(attrs[BATADV_ATTR_HARD_IFINDEX]);
	lastseen = nla_get_u32(attrs[BATADV_ATTR_LAST_SEEN_MSECS]);

	if (memcmp(orig, dest, 6) != 0)
		return NL_OK;

	ifname = if_indextoname(hardif, ifname_buf);
	if (!ifname)
		return NL_OK;

	sprintf(mac1, "%02x:%02x:%02x:%02x:%02x:%02x",
		orig[0], orig[1], orig[2], orig[3], orig[4], orig[5]);

	struct json_object *obj = json_object_new_object();
	if (!obj)
		return NL_OK;

	struct json_object *interface;
	if (!json_object_object_get_ex(opts->interfaces, ifname, &interface)) {
		interface = json_object_new_object();
		json_object_object_add(opts->interfaces, ifname, interface);
	}

	json_object_object_add(obj, "tq", json_object_new_int(tq));
	json_object_object_add(obj, "lastseen", json_object_new_double(lastseen / 1000.));
	json_object_object_add(interface, mac1, obj);

	return NL_OK;
}

static struct json_object * get_batadv(void) {
	struct neigh_netlink_opts opts = {
		.query_opts = {
			.err = 0,
		},
	};
	int ret;

	opts.interfaces = json_object_new_object();
	if (!opts.interfaces)
		return NULL;

	ret = batadv_genl_query("bat0", BATADV_CMD_GET_ORIGINATORS,
				parse_orig_list_netlink_cb, NLM_F_DUMP,
				&opts.query_opts);
	if (ret < 0) {
		json_object_put(opts.interfaces);
		return NULL;
	}

	return ifnames2addrs(opts.interfaces);
}

static struct json_object * get_wifi_neighbours(const char *ifname) {
	const struct iwinfo_ops *iw = iwinfo_backend(ifname);
	if (!iw)
		return NULL;

	int len;
	char buf[IWINFO_BUFSIZE];
	if (iw->assoclist(ifname, buf, &len) < 0)
		return NULL;

	struct json_object *neighbours = json_object_new_object();

	struct iwinfo_assoclist_entry *entry;
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++) {
		if (entry->inactive > MAX_INACTIVITY)
			continue;

		struct json_object *obj = json_object_new_object();

		json_object_object_add(obj, "signal", json_object_new_int(entry->signal));
		json_object_object_add(obj, "noise", json_object_new_int(entry->noise));
		json_object_object_add(obj, "inactive", json_object_new_int(entry->inactive));

		char mac[18];
		snprintf(mac, sizeof(mac), "%02x:%02x:%02x:%02x:%02x:%02x",
			 entry->mac[0], entry->mac[1], entry->mac[2],
			 entry->mac[3], entry->mac[4], entry->mac[5]);

		json_object_object_add(neighbours, mac, obj);
	}

	struct json_object *ret = json_object_new_object();

	if (json_object_object_length(neighbours))
		json_object_object_add(ret, "neighbours", neighbours);
	else
		json_object_put(neighbours);

	return ret;
}

static struct json_object * get_wifi(void) {
	const char *mesh = "bat0";

	struct json_object *ret = json_object_new_object();

	const char *format = "/sys/class/net/%s/lower_*";
	char pattern[strlen(format) + strlen(mesh)];
	snprintf(pattern, sizeof(pattern), format, mesh);

	size_t pattern_len = strlen(pattern);

	glob_t lower;
	if (!glob(pattern, GLOB_NOSORT, NULL, &lower)) {
		size_t i;
		for (i = 0; i < lower.gl_pathc; i++) {
			const char *ifname = lower.gl_pathv[i] + pattern_len - 1;
			char *ifaddr = gluonutil_get_interface_address(ifname);
			if (!ifaddr)
				continue;

			struct json_object *neighbours = get_wifi_neighbours(ifname);
			if (neighbours)
				json_object_object_add(ret, ifaddr, neighbours);

			free(ifaddr);
		}

		globfree(&lower);
	}

	return ret;
}

static struct json_object * respondd_provider_neighbours(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *batadv = get_batadv();
	if (batadv)
		json_object_object_add(ret, "batadv", batadv);

	struct json_object *wifi = get_wifi();
	if (wifi)
		json_object_object_add(ret, "wifi", wifi);

	return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{"statistics", respondd_provider_statistics},
	{"neighbours", respondd_provider_neighbours},
	{}
};
