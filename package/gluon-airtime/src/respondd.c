#include <string.h>
#include <stdio.h>
#include <json-c/json.h>
#include <respondd.h>

#include "airtime.h"
#include "ifaces.h"

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
	struct airtime_result airtime = {};
	struct json_object *result, *wireless;
	struct iface_list *ifaces;
	void *freeptr;

	result = json_object_new_object();
	if (!result)
		return NULL;

	wireless = json_object_new_array();
	if (!wireless) {
		json_object_put(result);
		return NULL;
	}

	ifaces = get_ifaces();
	while (ifaces != NULL) {
		get_airtime(&airtime, ifaces->ifx);
		fill_airtime_json(&airtime, wireless);
		freeptr = ifaces;
		ifaces = ifaces->next;
		free(freeptr);
	}

	json_object_object_add(result, "wireless", wireless);
	return result;
}

const struct respondd_provider_info respondd_providers[] = {
	{"statistics", respondd_provider_statistics},
	{0, 0},
};
