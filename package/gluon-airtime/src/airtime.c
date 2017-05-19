/*
  Copyright (c) 2016, Julian Kornberger <jk+freifunk@digineo.de>
                      Martin Müller <geno+ffhb@fireorbit.de>
                      Jan-Philipp Litza <janphilipp@litza.de>
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

#include <sys/socket.h>
#include <linux/nl80211.h>
#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <net/if.h>

#include "airtime.h"

/*
 * Excerpt from nl80211.h:
 * enum nl80211_survey_info - survey information
 *
 * These attribute types are used with %NL80211_ATTR_SURVEY_INFO
 * when getting information about a survey.
 *
 * @__NL80211_SURVEY_INFO_INVALID: attribute number 0 is reserved
 * @NL80211_SURVEY_INFO_FREQUENCY: center frequency of channel
 * @NL80211_SURVEY_INFO_NOISE: noise level of channel (u8, dBm)
 * @NL80211_SURVEY_INFO_IN_USE: channel is currently being used
 * @NL80211_SURVEY_INFO_CHANNEL_TIME: amount of time (in ms) that the radio
 *	spent on this channel
 * @NL80211_SURVEY_INFO_CHANNEL_TIME_BUSY: amount of the time the primary
 *	channel was sensed busy (either due to activity or energy detect)
 * @NL80211_SURVEY_INFO_CHANNEL_TIME_EXT_BUSY: amount of time the extension
 *	channel was sensed busy
 * @NL80211_SURVEY_INFO_CHANNEL_TIME_RX: amount of time the radio spent
 *	receiving data
 * @NL80211_SURVEY_INFO_CHANNEL_TIME_TX: amount of time the radio spent
 *	transmitting data
 * @NL80211_SURVEY_INFO_MAX: highest survey info attribute number
 *	currently defined
 * @__NL80211_SURVEY_INFO_AFTER_LAST: internal use
 */

static int survey_airtime_handler(struct nl_msg *msg, void *arg) {
	struct nlattr *tb[NL80211_ATTR_MAX + 1];
	struct nlattr *sinfo[NL80211_SURVEY_INFO_MAX + 1];
	static struct nla_policy survey_policy[NL80211_SURVEY_INFO_MAX + 1] = {
		[NL80211_SURVEY_INFO_FREQUENCY] = { .type = NLA_U32 },
		[NL80211_SURVEY_INFO_NOISE] = { .type = NLA_U8 },
	};

	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
	struct airtime_result *result = (struct airtime_result *) arg;

	nla_parse(tb, NL80211_ATTR_MAX, genlmsg_attrdata(gnlh, 0), genlmsg_attrlen(gnlh, 0), NULL);

	if (!tb[NL80211_ATTR_SURVEY_INFO]) {
		fprintf(stderr, "survey data missing!\n");
		goto abort;
	}

	if(nla_parse_nested(sinfo, NL80211_SURVEY_INFO_MAX, tb[NL80211_ATTR_SURVEY_INFO], survey_policy)) {
		fprintf(stderr, "failed to parse nested attributes!\n");
		goto abort;
	}

	// Channel active?
	if(!sinfo[NL80211_SURVEY_INFO_IN_USE]){
		goto abort;
	}

	result->frequency   = nla_get_u32(sinfo[NL80211_SURVEY_INFO_FREQUENCY]);
	result->active_time = nla_get_u64(sinfo[NL80211_SURVEY_INFO_CHANNEL_TIME]);
	result->busy_time   = nla_get_u64(sinfo[NL80211_SURVEY_INFO_CHANNEL_TIME_BUSY]);
	result->rx_time     = nla_get_u64(sinfo[NL80211_SURVEY_INFO_CHANNEL_TIME_RX]);
	result->tx_time     = nla_get_u64(sinfo[NL80211_SURVEY_INFO_CHANNEL_TIME_TX]);
	result->noise       = nla_get_u8(sinfo[NL80211_SURVEY_INFO_NOISE]);

abort:
	return NL_SKIP;
}

int get_airtime(struct airtime_result *result, int ifx) {
	int error = 0;
	int ctrl;
	struct nl_sock *sk = NULL;
	struct nl_msg *msg = NULL;

#define CHECK(x) { if (!(x)) { fprintf(stderr, "airtime.c: error on line %d\n",  __LINE__); error = 1; goto out; } }

	CHECK(sk = nl_socket_alloc());
	CHECK(genl_connect(sk) >= 0);

	CHECK(ctrl = genl_ctrl_resolve(sk, NL80211_GENL_NAME));
	CHECK(nl_socket_modify_cb(sk, NL_CB_VALID, NL_CB_CUSTOM, survey_airtime_handler, result) == 0);
	CHECK(msg = nlmsg_alloc());

	/* TODO: check return? */
	genlmsg_put(msg, 0, 0, ctrl, 0, NLM_F_DUMP, NL80211_CMD_GET_SURVEY, 0);

	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, ifx);

	CHECK(nl_send_auto_complete(sk, msg) >= 0);
	CHECK(nl_recvmsgs_default(sk) >= 0);

#undef CHECK

nla_put_failure:
out:
	if (msg)
		nlmsg_free(msg);

	if (sk)
		nl_socket_free(sk);

	return error;
}
