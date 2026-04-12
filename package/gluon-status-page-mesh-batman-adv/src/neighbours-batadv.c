#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>
#include <net/if.h>

#include <batadv-genl.h>

#define STR(x) #x
#define XSTR(x) STR(x)

struct neigh_netlink_opts {
	struct json_object *obj;
	bool is_batman_v;
	struct batadv_nlquery_opts query_opts;
};

/* Batman IV mandatory attrs */
static const enum batadv_nl_attrs parse_orig_list_mandatory_batadv_iv[] = {
	BATADV_ATTR_ORIG_ADDRESS,
	BATADV_ATTR_NEIGH_ADDRESS,
	BATADV_ATTR_TQ,
	BATADV_ATTR_HARD_IFINDEX,
	BATADV_ATTR_LAST_SEEN_MSECS,
};

/* Batman V mandatory attrs */
static const enum batadv_nl_attrs parse_neigh_list_mandatory_batadv_v[] = {
	BATADV_ATTR_NEIGH_ADDRESS,
	BATADV_ATTR_THROUGHPUT,
	BATADV_ATTR_HARD_IFINDEX,
	BATADV_ATTR_LAST_SEEN_MSECS,
};

static int parse_orig_neigh_list_netlink_cb(struct nl_msg *msg, void *arg)
{
	struct nlattr *attrs[BATADV_ATTR_MAX+1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	struct batadv_nlquery_opts *query_opts = arg;
	struct genlmsghdr *ghdr;
	uint8_t *mac;
	uint32_t hardif;
	char ifname_buf[IF_NAMESIZE], *ifname;
	struct neigh_netlink_opts *opts;
	char mac1[18];

	opts = batadv_container_of(query_opts, struct neigh_netlink_opts, query_opts);

	if (!genlmsg_valid_hdr(nlh, 0))
		return NL_OK;

	ghdr = nlmsg_data(nlh);

	if (nla_parse(attrs, BATADV_ATTR_MAX, genlmsg_attrdata(ghdr, 0),
				genlmsg_len(ghdr), batadv_genl_policy))
		return NL_OK;

	if (opts->is_batman_v) {
		if (ghdr->cmd != BATADV_CMD_GET_NEIGHBORS)
			return NL_OK;

		if (batadv_genl_missing_attrs(attrs, parse_neigh_list_mandatory_batadv_v,
					BATADV_ARRAY_SIZE(parse_neigh_list_mandatory_batadv_v)))
			return NL_OK;

		mac = nla_data(attrs[BATADV_ATTR_NEIGH_ADDRESS]);
	} else {
		if (ghdr->cmd != BATADV_CMD_GET_ORIGINATORS)
			return NL_OK;

		if (batadv_genl_missing_attrs(attrs, parse_orig_list_mandatory_batadv_iv,
					BATADV_ARRAY_SIZE(parse_orig_list_mandatory_batadv_iv)))
			return NL_OK;

		mac = nla_data(attrs[BATADV_ATTR_ORIG_ADDRESS]);
		if (memcmp(mac, nla_data(attrs[BATADV_ATTR_NEIGH_ADDRESS]), 6) != 0)
			return NL_OK;
	}

	hardif = nla_get_u32(attrs[BATADV_ATTR_HARD_IFINDEX]);

	ifname = if_indextoname(hardif, ifname_buf);
	if (!ifname)
		return NL_OK;

	sprintf(mac1, "%02x:%02x:%02x:%02x:%02x:%02x",
			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

	struct json_object *neigh = json_object_new_object();
	if (!neigh)
		return NL_OK;

	if (opts->is_batman_v) {
		uint32_t throughput = nla_get_u32(attrs[BATADV_ATTR_THROUGHPUT]);
		char tp_str[5];
		const char tp_units[] = {'k', 'M', 'G', 'T', '?'};
		int tp_unit;

		for (tp_unit = 0; tp_unit < 4; tp_unit++) {
			if (throughput < 1000)
				break;
			throughput /= 1000;
		}
		sprintf(tp_str, "%3u%c", throughput, tp_units[tp_unit]);

		json_object_object_add(neigh, "tp", json_object_new_string(tp_str));
	} else {
		uint8_t tq = nla_get_u8(attrs[BATADV_ATTR_TQ]);
		json_object_object_add(neigh, "tq", json_object_new_int(tq * 100 / 255));
	}

	json_object_object_add(neigh, "ifname", json_object_new_string(ifname));
	json_object_object_add(neigh, "best", json_object_new_boolean(nla_get_flag(attrs[BATADV_ATTR_FLAG_BEST])));

	json_object_object_add(opts->obj, mac1, neigh);

	return NL_OK;
}

static json_object *neighbours(void) {
	struct neigh_netlink_opts opts = {
		.query_opts = {
			.err = 0,
		},
	};
	int ret;
	char algoname[256];

	opts.obj = json_object_new_object();
	if (!opts.obj)
		return NULL;

	if (batadv_genl_get_algoname("bat0", algoname, sizeof(algoname)) < 0) {
		json_object_put(opts.obj);
		return NULL;
	}

	if (strcmp(algoname, "BATMAN_V") == 0) {
		opts.is_batman_v = true;
		ret = batadv_genl_query("bat0", BATADV_CMD_GET_NEIGHBORS,
				parse_orig_neigh_list_netlink_cb, NLM_F_DUMP,
				&opts.query_opts);
	} else if (strcmp(algoname, "BATMAN_IV") == 0) {
		opts.is_batman_v = false;
		ret = batadv_genl_query("bat0", BATADV_CMD_GET_ORIGINATORS,
				parse_orig_neigh_list_netlink_cb, NLM_F_DUMP,
				&opts.query_opts);
	} else {
		json_object_put(opts.obj);
		return NULL;
	}

	if (ret < 0) {
		json_object_put(opts.obj);
		return NULL;
	}

	return opts.obj;
}

int main(void) {
	struct json_object *obj;

	printf("Content-type: text/event-stream\n\n");
	fflush(stdout);

	while (1) {
		obj = neighbours();
		if (obj) {
			printf("data: %s\n\n", json_object_to_json_string_ext(obj, JSON_C_TO_STRING_PLAIN));
			fflush(stdout);
			json_object_put(obj);
		}
		sleep(10);
	}

	return 0;
}
