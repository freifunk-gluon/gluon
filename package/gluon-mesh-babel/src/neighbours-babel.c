#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <json-c/json.h>
#include <libbabelhelper/babelhelper.h>
#include "handle_neighbour.h"

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
		babelhelper_readbabeldata(&bhelper_ctx, (void*)neighbours, handle_neighbour);

		printf("data: %s\n\n", json_object_to_json_string(neighbours));
		fflush(stdout);
		json_object_put(neighbours);
		neighbours = NULL;
		sleep(10);
	}

	return 0;
}
