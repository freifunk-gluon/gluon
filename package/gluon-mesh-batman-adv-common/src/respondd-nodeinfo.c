/* SPDX-FileCopyrightText: 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */

#include "respondd-common.h"

#include <libgluonutil.h>

#include <json-c/json.h>

#include <netlink/netlink.h>
#include <netlink/msg.h>

#include <glob.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/in.h>

#include <linux/if_addr.h>
#include <linux/rtnetlink.h>


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

	/* In case of VLAN and bridge interfaces, we want the lower interface
	 * to determine the interface type (but not for the interface address) */
	char lowername[IF_NAMESIZE];
	gluonutil_get_interface_lower(lowername, ifname);

	switch(gluonutil_get_interface_type(lowername)) {
	case GLUONUTIL_INTERFACE_TYPE_WIRELESS:
		json_object_array_add(wireless, address);
		break;

	case GLUONUTIL_INTERFACE_TYPE_TUNNEL:
		json_object_array_add(tunnel, address);
		break;

	default:
		json_object_array_add(other, address);
	}
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

struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *network = json_object_new_object();
	json_object_object_add(network, "addresses", get_addresses());
	json_object_object_add(network, "mesh", get_mesh());
	json_object_object_add(ret, "network", network);

	struct json_object *software = json_object_new_object();
	struct json_object *software_batman_adv = json_object_new_object();
	json_object_object_add(software_batman_adv, "version",
		gluonutil_wrap_and_free_string(gluonutil_read_line("/sys/module/batman_adv/version")));
	json_object_object_add(software_batman_adv, "compat", json_object_new_int(15));
	json_object_object_add(software, "batman-adv", software_batman_adv);
	json_object_object_add(ret, "software", software);

	return ret;
}
