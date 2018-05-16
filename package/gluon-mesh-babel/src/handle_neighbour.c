#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "handle_neighbour.h"
#include <libbabelhelper/babelhelper.h>

bool handle_neighbour(char **data, void *arg) {
	struct json_object *obj = (struct json_object*)arg;

	if (data[NEIGHBOUR]) {
		struct json_object *neigh = json_object_new_object();

		if (data[RXCOST])
			json_object_object_add(neigh, "rxcost", json_object_new_int(atoi(data[RXCOST])));
		if (data[TXCOST])
			json_object_object_add(neigh, "txcost", json_object_new_int(atoi(data[TXCOST])));
		if (data[COST])
			json_object_object_add(neigh, "cost", json_object_new_int(atoi(data[COST])));
		if (data[REACH])
			json_object_object_add(neigh, "reachability", json_object_new_double(strtod(data[REACH], NULL)));
		if (data[IF])
			json_object_object_add(neigh, "ifname", json_object_new_string(data[IF]));
		if (data[ADDRESS])
			json_object_object_add(obj, data[ADDRESS] , neigh);
	}
	return true;
}
