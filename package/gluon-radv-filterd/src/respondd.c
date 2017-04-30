#include <respondd.h>

#include <json-c/json.h>
#include <libgluonutil.h>
#include <stdio.h>

#include "mac.h"

static struct json_object * get_radv_filter() {
	FILE *f = popen("exec ebtables -L RADV_FILTER", "r");
	char *line = NULL;
	size_t len = 0;
	macaddr_t mac = {};
	struct json_object *ret = NULL;
	char macstr[F_MAC_LEN + 1] = "";

	if (!f)
		return NULL;

	while (getline(&line, &len, f) > 0) {
		if (sscanf(line, "-s " F_MAC " -j ACCEPT\n", F_MAC_VAR_REF(mac)) == ETH_ALEN)
			break;
	}
	free(line);

	pclose(f);

	snprintf(macstr, sizeof(macstr), F_MAC, F_MAC_VAR(mac));
	ret = gluonutil_wrap_string(macstr);
	return ret;
}

static struct json_object * respondd_provider_statistics() {
	struct json_object *ret = json_object_new_object();

	struct json_object *radv_filter = get_radv_filter();
	if (radv_filter)
		json_object_object_add(ret, "gateway6", radv_filter);

	return ret;
}

const struct respondd_provider_info respondd_providers[] = {
	{"statistics", respondd_provider_statistics},
	{}
};
