/*
  Copyright (c) 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net>
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

#include "respondd-common.h"

#include <batadv-genl.h>
#include <libgluonutil.h>

#include <json-c/json.h>

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <net/if.h>


struct neigh_netlink_opts {
	struct json_object *interfaces;
	struct batadv_nlquery_opts query_opts;
};


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

void increment_json_int_by_key(struct json_object *obj, const char *key) {
	struct json_object *old_obj;
	int new_val;

	json_object_object_get_ex(obj, key, &old_obj);
	new_val = json_object_get_int(old_obj)+1;
	json_object_object_del(obj, key);

	json_object_object_add(obj, key, json_object_new_int(new_val));

}

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

	orig = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);
	dest = nla_data(attrs[BATADV_ATTR_NEIGH_ADDRESS]);
	tq = nla_get_u8(attrs[BATADV_ATTR_TQ]);
	hardif = nla_get_u32(attrs[BATADV_ATTR_HARD_IFINDEX]);
	lastseen = nla_get_u32(attrs[BATADV_ATTR_LAST_SEEN_MSECS]);

	ifname = if_indextoname(hardif, ifname_buf);
	if (!ifname)
		return NL_OK;

	sprintf(mac1, "%02x:%02x:%02x:%02x:%02x:%02x",
		dest[0], dest[1], dest[2], dest[3], dest[4], dest[5]);

	struct json_object *interface;
	if (!json_object_object_get_ex(opts->interfaces, ifname, &interface)) {
		interface = json_object_new_object();
		json_object_object_add(opts->interfaces, ifname, interface);
	}

	struct json_object *obj;
	struct json_object *routes;
	if (!json_object_object_get_ex(interface, mac1, &obj)) {
		obj = json_object_new_object();
		json_object_object_add(interface, mac1, obj);
		routes = json_object_new_object();
		json_object_object_add(routes, "imported", json_object_new_int(0));
		json_object_object_add(routes, "selected", json_object_new_int(0));
		json_object_object_add(obj, "routes", routes);
	}

	if (!routes) {
		json_object_object_get_ex(obj, "routes", &routes);
	}

	if (!!attrs[BATADV_ATTR_FLAG_BEST]) {
		increment_json_int_by_key(routes, "selected");
	}

	increment_json_int_by_key(routes, "imported");

	if (memcmp(orig, dest, 6) != 0) {
		return NL_OK;
	}

	json_object_object_add(obj, "tq", json_object_new_int(tq));
	json_object_object_add(obj, "lastseen", json_object_new_double(lastseen / 1000.));
	json_object_object_add(obj, "best", json_object_new_boolean(!!attrs[BATADV_ATTR_FLAG_BEST]));

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

struct json_object * respondd_provider_neighbours(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *batadv = get_batadv();
	if (batadv)
		json_object_object_add(ret, "batadv", batadv);

	return ret;
}
