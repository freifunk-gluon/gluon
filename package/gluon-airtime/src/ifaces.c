#include <sys/socket.h>
#include <linux/nl80211.h>
#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <net/if.h>
#include <stdlib.h>

#include "ifaces.h"

static int iface_dump_handler(struct nl_msg *msg, struct iface_list **arg) {
	struct nlattr *tb[NL80211_ATTR_MAX + 1];
	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
	int wiphy;
	struct iface_list **last_next;

	nla_parse(tb, NL80211_ATTR_MAX, genlmsg_attrdata(gnlh, 0), genlmsg_attrlen(gnlh, 0), NULL);

	wiphy = nla_get_u32(tb[NL80211_ATTR_WIPHY]);
	for (last_next = arg; *last_next != NULL; last_next = &(*last_next)->next) {
		if ((*last_next)->wiphy == wiphy)
			goto abort;
	}
	*last_next = malloc(sizeof(**last_next));
	(*last_next)->next = NULL;
	(*last_next)->ifx = nla_get_u32(tb[NL80211_ATTR_IFINDEX]);
	(*last_next)->wiphy = wiphy;

abort:
	return NL_SKIP;
}

struct iface_list *get_ifaces() {
	int ctrl;
	struct nl_sock *sk = NULL;
	struct nl_msg *msg = NULL;
	struct iface_list *ifaces = NULL;

#define CHECK(x) { if (!(x)) { fprintf(stderr, "airtime.c: error on line %d\n",  __LINE__); goto out; } }

	CHECK(sk = nl_socket_alloc());
	CHECK(genl_connect(sk) >= 0);

	CHECK(ctrl = genl_ctrl_resolve(sk, NL80211_GENL_NAME));
	CHECK(nl_socket_modify_cb(sk, NL_CB_VALID, NL_CB_CUSTOM, (nl_recvmsg_msg_cb_t) iface_dump_handler, &ifaces) == 0);
	CHECK(msg = nlmsg_alloc());

	/* TODO: check return? */
	genlmsg_put(msg, 0, 0, ctrl, 0, NLM_F_DUMP, NL80211_CMD_GET_INTERFACE, 0);

	CHECK(nl_send_auto_complete(sk, msg) >= 0);
	CHECK(nl_recvmsgs_default(sk) >= 0);

#undef CHECK

out:
	if (msg)
		nlmsg_free(msg);

	if (sk)
		nl_socket_free(sk);

	return ifaces;
}
