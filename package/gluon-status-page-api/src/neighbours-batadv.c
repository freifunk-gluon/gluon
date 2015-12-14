#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>
#include <net/if.h>

#define STR(x) #x
#define XSTR(x) STR(x)

static json_object *neighbours(void) {
  struct json_object *obj = json_object_new_object();

  FILE *f;

  f = fopen("/tmp/batman-adv-visdata/bat0/originators" , "r");

  if (f == NULL)
    return NULL;

  while (!feof(f)) {
    char mac1[18];
    char mac2[18];
    char ifname[IF_NAMESIZE+1];
    int tq;
    double lastseen;

    int count = fscanf(f, "%17s%*[\t ]%lfs%*[\t (]%d) %17s%*[[ ]%" XSTR(IF_NAMESIZE) "[^]]]", mac1, &lastseen, &tq, mac2, ifname);

    if (count != 5)
      continue;

    if (strcmp(mac1, mac2) == 0) {
      struct json_object *neigh = json_object_new_object();

      json_object_object_add(neigh, "tq", json_object_new_int(tq));
      json_object_object_add(neigh, "lastseen", json_object_new_double(lastseen));
      json_object_object_add(neigh, "ifname", json_object_new_string(ifname));

      json_object_object_add(obj, mac1, neigh);
    }
  }

  fclose(f);

  return obj;
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
