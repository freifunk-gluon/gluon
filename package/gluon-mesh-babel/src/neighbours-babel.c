#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>
#include <stdlib.h>
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

int main(void) {
	struct json_object *neighbours;

	printf("Content-type: text/event-stream\n\n");
	fflush(stdout);

	struct babelhelper_ctx bhelper_ctx = {};
	while (1) {
		neighbours = json_object_new_object();
		if (!neighbours)
			continue;

		bhelper_ctx.debug = false;
		babelhelper_readbabeldata(&bhelper_ctx, "dump", (void*)neighbours, handle_neighbour);

		printf("data: %s\n\n", json_object_to_json_string(neighbours));
		fflush(stdout);
		json_object_put(neighbours);
		neighbours = NULL;
		sleep(10);
	}

	return 0;
}
