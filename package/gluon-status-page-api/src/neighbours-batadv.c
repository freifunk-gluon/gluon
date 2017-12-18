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
  struct batadv_nlquery_opts query_opts;
};

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

  opts = batadv_container_of(query_opts, struct neigh_netlink_opts, query_opts);

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

  struct json_object *neigh = json_object_new_object();
  if (!neigh)
    return NL_OK;

  json_object_object_add(neigh, "tq", json_object_new_int(tq));
  json_object_object_add(neigh, "lastseen", json_object_new_double(lastseen / 1000.));
  json_object_object_add(neigh, "ifname", json_object_new_string(ifname));

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

  opts.obj = json_object_new_object();
  if (!opts.obj)
    return NULL;

  ret = batadv_genl_query("bat0", BATADV_CMD_GET_ORIGINATORS,
                          parse_orig_list_netlink_cb, NLM_F_DUMP,
                          &opts.query_opts);
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
