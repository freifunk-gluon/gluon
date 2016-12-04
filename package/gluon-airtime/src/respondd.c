#include <string.h>
#include <stdio.h>
#include <json-c/json.h>
#include <respondd.h>

#include "airtime.h"

static const char const *wifi_0_dev = "client0";
static const char const *wifi_1_dev = "client1";

void fill_airtime_json(struct airtime_result *air, struct json_object *wireless) {
	struct json_object *obj = NULL;

	obj = json_object_new_object();
	if(!obj)
		return;

	json_object_object_add(obj, "frequency", json_object_new_int(air->frequency));
	json_object_object_add(obj, "active",    json_object_new_int64(air->active_time));
	json_object_object_add(obj, "busy",      json_object_new_int64(air->busy_time));
	json_object_object_add(obj, "rx",        json_object_new_int64(air->rx_time));
	json_object_object_add(obj, "tx",        json_object_new_int64(air->tx_time));
	json_object_object_add(obj, "noise",     json_object_new_int(air->noise));

	json_object_array_add(wireless, obj);
}

static struct json_object *respondd_provider_statistics(void) {
	struct airtime *airtime = NULL;
	struct json_object *result, *wireless;

	airtime = get_airtime(wifi_0_dev, wifi_1_dev);
	if (!airtime)
		return NULL;

	result = json_object_new_object();
	if (!result)
		return NULL;

	wireless = json_object_new_array();
	if (!wireless) {
		json_object_put(result);
		return NULL;
	}

	if (airtime->radio0.frequency)
		fill_airtime_json(&airtime->radio0, wireless);

	if (airtime->radio1.frequency)
		fill_airtime_json(&airtime->radio1, wireless);

	json_object_object_add(result, "wireless", wireless);
	return result;
}

const struct respondd_provider_info respondd_providers[] = {
	{"statistics", respondd_provider_statistics},
	{0, 0},
};
