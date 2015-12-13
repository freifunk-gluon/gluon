#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>
#include <iwinfo.h>
#include <net/if.h>


static struct json_object *get_stations(const struct iwinfo_ops *iw, const char *ifname) {
  int len;
  char buf[IWINFO_BUFSIZE];
  struct json_object *stations = json_object_new_object();

  if (iw->assoclist(ifname, buf, &len) == -1)
    return stations;

  // This is just: for entry in assoclist(ifname)
  for (struct iwinfo_assoclist_entry *entry = (struct iwinfo_assoclist_entry *)buf;
      (char*)(entry+1) <= buf + len; entry++) {
    struct json_object *station = json_object_new_object();

    json_object_object_add(station, "signal", json_object_new_int(entry->signal));
    json_object_object_add(station, "noise", json_object_new_int(entry->noise));
    json_object_object_add(station, "inactive", json_object_new_int(entry->inactive));

    char macstr[18];

    snprintf(macstr, sizeof(macstr), "%02x:%02x:%02x:%02x:%02x:%02x",
        entry->mac[0], entry->mac[1], entry->mac[2],
        entry->mac[3], entry->mac[4], entry->mac[5]);

    json_object_object_add(stations, macstr, station);
  }

  return stations;
}

static void badrequest() {
  printf("Status: 400 Bad Request\n\n");
  exit(1);
}

int main(int argc, char *argv[]) {
  if (argc != 2)
    badrequest();

  const char *ifname = argv[1];
  const struct iwinfo_ops *iw = iwinfo_backend(ifname);

  if (iw == NULL)
    badrequest();

  printf("Content-type: text/event-stream\n\n");

  while (true) {
    struct json_object *obj;
    obj = get_stations(iw, ifname);
    printf("data: %s\n\n", json_object_to_json_string_ext(obj, JSON_C_TO_STRING_PLAIN));
    fflush(stdout);
    json_object_put(obj);
    usleep(150000);
  }

  return 0;
}
