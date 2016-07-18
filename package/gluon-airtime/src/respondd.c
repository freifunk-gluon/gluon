#include <string.h>
#include <stdio.h>
#include <json-c/json.h>
#include <respondd.h>

#include "airtime.h"

static const char const *wifi_0_dev = "client0";
static const char const *wifi_1_dev = "client1";

void fill_airtime_json(struct airtime_result *air, struct json_object* wireless){
	struct json_object *result = NULL, *obj = NULL;

	obj = json_object_new_object();
	if(!obj)
		goto error;
#define JSON_ADD_INT64(value,key) {result = json_object_new_int64(value); json_object_object_add(obj,key,result);}
	result = json_object_new_int(air->frequency);
	if(!result)
		goto error;
	json_object_object_add(obj,"frequency",result);

	JSON_ADD_INT64(air->active_time.current,"active")
	JSON_ADD_INT64(air->busy_time.current,"busy")
	JSON_ADD_INT64(air->rx_time.current,"rx")
	JSON_ADD_INT64(air->tx_time.current,"tx")

	result = json_object_new_int(air->noise);
	json_object_object_add(obj,"noise",result);

error:
	if(air->frequency >= 2400  && air->frequency < 2500)
		json_object_object_add(wireless, "airtime24", obj);
	else if (air->frequency >= 5000 && air->frequency < 6000)
		json_object_object_add(wireless, "airtime5", obj);
}

static struct json_object *respondd_provider_statistics(void) {
	struct airtime *airtime = NULL;
	struct json_object *result = NULL, *wireless = NULL;

	airtime = get_airtime(wifi_0_dev, wifi_1_dev);
	if (!airtime)
		return NULL;

	result = json_object_new_object();
	if (!result)
		return NULL;

	wireless = json_object_new_object();
	if (!wireless){
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
