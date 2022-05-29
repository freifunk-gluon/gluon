#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>

#include <libubox/uclient.h>
#include <libubox/blobmsg.h>
#include <libubox/uloop.h>
#include <libolsrdhelper.h>

static json_object *neighbours(void) {
  json_object *resp;
  if (olsr1_get_nodeinfo("links", &resp))
    return NULL;

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

  // TODO: use olsr1_get_neigh and olsr2_get_neigh, iterate over both, then copy stuffs into the right format (and use mac as primary)

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

    json_object_object_add(out, json_object_get_string(json_object_object_get(link, "remoteIP")), neigh);
  }

  return out;
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
