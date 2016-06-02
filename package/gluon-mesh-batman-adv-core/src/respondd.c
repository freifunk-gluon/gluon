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

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include <linux/ethtool.h>
#include <linux/if_addr.h>
#include <linux/sockios.h>



#define _STRINGIFY(s) #s
#define STRINGIFY(s) _STRINGIFY(s)


static struct json_object * get_addresses(void) {
	FILE *f = fopen("/proc/net/if_inet6", "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;

	struct json_object *ret = json_object_new_array();

	while (getline(&line, &len, f) >= 0) {
		/* IF_NAMESIZE would be enough, but adding 1 here is simpler than subtracting 1 in the format string */
		char ifname[IF_NAMESIZE+1];
		unsigned int flags;
		struct in6_addr addr;
		char buf[INET6_ADDRSTRLEN];

		if (sscanf(line,
			   "%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8
			   "%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8"%2"SCNx8
			   "  %*2x %*2x %*2x %2x %"STRINGIFY(IF_NAMESIZE)"s",
			   &addr.s6_addr[0], &addr.s6_addr[1], &addr.s6_addr[2], &addr.s6_addr[3],
			   &addr.s6_addr[4], &addr.s6_addr[5], &addr.s6_addr[6], &addr.s6_addr[7],
			   &addr.s6_addr[8], &addr.s6_addr[9], &addr.s6_addr[10], &addr.s6_addr[11],
			   &addr.s6_addr[12], &addr.s6_addr[13], &addr.s6_addr[14], &addr.s6_addr[15],
			   &flags, ifname) != 18)
			continue;

		if (strcmp(ifname, "br-client"))
			continue;

		if (flags & (IFA_F_TENTATIVE|IFA_F_DEPRECATED))
			continue;

		inet_ntop(AF_INET6, &addr, buf, sizeof(buf));

		json_object_array_add(ret, json_object_new_string(buf));
	}

	fclose(f);
	free(line);

	return ret;
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

	if (interface_file_exists(ifname, "wireless"))
		json_object_array_add(wireless, address);
	else if (interface_file_exists(ifname, "tun_flags"))
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
	FILE *f = fopen("/lib/gluon/mesh-batman-adv-core/compat", "r");
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


static void add_gateway(struct json_object *obj) {
	FILE *f = fopen("/sys/kernel/debug/batman_adv/bat0/gateways", "r");
	if (!f)
		return;

	char *line = NULL;
	size_t len = 0;

	while (getline(&line, &len, f) >= 0) {
		char addr[18];
		char nexthop[18];

		if (sscanf(line, "=> %17[0-9a-fA-F:] ( %*u) %17[0-9a-fA-F:]", addr, nexthop) != 2)
			continue;

		json_object_object_add(obj, "gateway", json_object_new_string(addr));
		json_object_object_add(obj, "gateway_nexthop", json_object_new_string(nexthop));
		break;
	}

	free(line);
	fclose(f);
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
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++)
		(*wifi)++;
}

static void count_stations(size_t *wifi24, size_t *wifi5) {
	struct uci_context *ctx = uci_alloc_context();
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

static struct json_object * get_clients(void) {
	size_t total = 0, wifi = 0, wifi24 = 0, wifi5 = 0;

	FILE *f = fopen("/sys/kernel/debug/batman_adv/bat0/transtable_local", "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;

	while (getline(&line, &len, f) >= 0) {
		char flags[16];

		if (sscanf(line, " * %*[^[] [%15[^]]]", flags) != 1)
			continue;

		if (strchr(flags, 'P'))
			continue;

		total++;

		if (strchr(flags, 'W'))
			wifi++;
	}

	free(line);
	fclose(f);

	count_stations(&wifi24, &wifi5);

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

static struct json_object * get_batadv(void) {
	FILE *f = fopen("/sys/kernel/debug/batman_adv/bat0/originators", "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;

	struct json_object *interfaces = json_object_new_object();

	while (getline(&line, &len, f) >= 0) {
		char mac1[18], mac2[18];
		/* IF_NAMESIZE would be enough, but adding 1 here is simpler than subtracting 1 in the format string */
		char ifname[IF_NAMESIZE+1];
		double lastseen;
		int tq;

		if (sscanf(line,
			   "%17[0-9a-fA-F:] %lfs ( %i ) %17[0-9a-fA-F:] [ %"STRINGIFY(IF_NAMESIZE)"[^]] ]",
			   mac1, &lastseen, &tq, mac2, ifname) != 5)
			continue;

		if (strcmp(mac1, mac2))
			continue;

		struct json_object *interface;
		if (!json_object_object_get_ex(interfaces, ifname, &interface)) {
			interface = json_object_new_object();
			json_object_object_add(interfaces, ifname, interface);
		}

		struct json_object *obj = json_object_new_object();
		json_object_object_add(obj, "tq", json_object_new_int(tq));
		struct json_object *jso = json_object_new_double(lastseen);
		json_object_set_serializer(jso, json_object_double_to_json_string, "%.3f", NULL);
		json_object_object_add(obj, "lastseen", jso);
		json_object_object_add(interface, mac1, obj);
	}

	fclose(f);
	free(line);

	return ifnames2addrs(interfaces);
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
