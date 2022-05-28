/*
  Copyright (c) 2021, Maciej Krüger <maciej@xeredo.it>
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

#include "libolsrdhelper.h"

struct json_object * olsr1_get_neigh(void) {
	json_object *resp;
  int error = olsr1_get_nodeinfo("links", &resp);

  if (error) {
    return NULL;
  }

  json_object *out = json_object_new_object();

  if (!out)
    return NULL;

  /*

  links

  localIP	"10.12.11.43"
  remoteIP	"10.12.11.1"
  olsrInterface	"mesh-vpn"
  ifName	"mesh-vpn"
  validityTime	141239
  symmetryTime	123095
  asymmetryTime	25552910
  vtime	124000
  currentLinkStatus	"SYMMETRIC"
  previousLinkStatus	"SYMMETRIC"
  hysteresis	0
  pending	false
  lostLinkTime	0
  helloTime	0
  lastHelloTime	0
  seqnoValid	false
  seqno	0
  lossHelloInterval	3000
  lossTime	3595
  lossMultiplier	65536
  linkCost	1.084961
  linkQuality	1
  neighborLinkQuality	0.921

  */

	json_object *links = json_object_object_get(resp, "links");
	if (!links)
		return NULL;

	int linkcount = json_object_array_length(links);

	for (int i = 0; i < linkcount; i++) {
		struct json_object *link = json_object_array_get_idx(links, i);
		if (!link)
			return NULL;

    struct json_object *neigh = json_object_new_object();
    if (!neigh)
      return NULL;

    json_object_object_add(neigh, "ifname", json_object_object_get(link, "ifName"));
		// TODO: do we need this? should we set this? (we could pick the one peer that we currently route 0.0.0.0 over...)
		json_object_object_add(neigh, "best", json_object_new_boolean(0));
		json_object_object_add(neigh, "etx", json_object_object_get(link, "etx"));
    json_object_object_add(neigh, "ip", json_object_object_get(link, "remoteIP"));

    json_object_object_add(out, json_object_get_string(json_object_object_get(link, "remoteIP")), neigh);
  }

  return out;
}

struct json_object * olsr2_get_neigh(void) {
	json_object *resp;
  int error = olsr2_get_nodeinfo("nhdpinfo jsonraw link", &resp);

  if (error) {
    return NULL;
  }

  json_object *out = json_object_new_object();

  if (!out)
    return NULL;

  /*

  links

	"if":"olsr12",
	"link_bindto":"fe80::ec67:efff:fed3:d856",
	"link_vtime_value":20,
	"link_itime_value":2,
	"link_symtime":19.786,
	"link_heardtime":19.886,
	"link_vtime":39.886,
	"link_status":"symmetric",
	"link_dualstack":"-",
	"link_mac":"b2:d6:9d:88:c1:58",
	"link_flood_local":"true",
	"link_flood_remote":"true",
	"link_flood_willingness":7,
	"neighbor_originator":"fdff:182f:da60:abc::66",
	"neighbor_dualstack":"-",
	"domain":0,
	"domain_metric":"ff_dat_metric",
	"domain_metric_in":"1.02kbit/s",
	"domain_metric_in_raw":2105088,
	"domain_metric_out":"1.02kbit/s",
	"domain_metric_out_raw":2105088,

  */

	json_object *links = json_object_object_get(resp, "link");
	if (!links)
		return NULL;

	int linkcount = json_object_array_length(links);

	for (int i = 0; i < linkcount; i++) {
		struct json_object *link = json_object_array_get_idx(links, i);
		if (!link)
			return NULL;

    struct json_object *neigh = json_object_new_object();
    if (!neigh)
      return NULL;

    json_object_object_add(neigh, "ifname", json_object_object_get(link, "if"));
		// TODO: do we need this? should we set this? (we could pick the one peer that we currently route 0.0.0.0 over...)
		json_object_object_add(neigh, "best", json_object_new_boolean(0));
		json_object_object_add(neigh, "etx", json_object_object_get(link, "link_vtime"));
    json_object_object_add(neigh, "ip", json_object_object_get(link, "neighbor_originator"));

    json_object_object_add(out, json_object_get_string(json_object_object_get(link, "link_mac")), neigh);
  }

  return out;
}
