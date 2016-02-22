/*
  Copyright (c) 2016, Matthias Schiffer <mschiffer@universe-factory.net>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#include "libgluonutil.h"

#include <json-c/json.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>


char * gluonutil_read_line(const char *filename) {
	FILE *f = fopen(filename, "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;

	ssize_t r = getline(&line, &len, f);

	fclose(f);

	if (r >= 0) {
		len = strlen(line);

		if (len && line[len-1] == '\n')
			line[len-1] = 0;
	}
	else {
		free(line);
		line = NULL;
	}

	return line;
}

char * gluonutil_get_sysconfig(const char *key) {
	if (strchr(key, '/'))
		return NULL;

	const char prefix[] = "/lib/gluon/core/sysconfig/";
	char path[strlen(prefix) + strlen(key) + 1];
	snprintf(path, sizeof(path), "%s%s", prefix, key);

	return gluonutil_read_line(path);
}

char * gluonutil_get_node_id(void) {
	char *node_id = gluonutil_get_sysconfig("primary_mac");
	if (!node_id)
		return NULL;

	char *in = node_id, *out = node_id;

	do {
		if (*in != ':')
			*out++ = *in;
	} while (*in++);

	return node_id;
}

char * gluonutil_get_interface_address(const char *ifname) {
	const char *format = "/sys/class/net/%s/address";
	char path[strlen(format) + strlen(ifname) - 1];

	snprintf(path, sizeof(path), format, ifname);

	return gluonutil_read_line(path);
}



struct json_object * gluonutil_wrap_string(const char *str) {
	if (!str)
		return NULL;

	return json_object_new_string(str);
}

struct json_object * gluonutil_wrap_and_free_string(char *str) {
	struct json_object *ret = gluonutil_wrap_string(str);
	free(str);
	return ret;
}

struct json_object * gluonutil_load_site_config(void) {
	return json_object_from_file("/lib/gluon/site.json");
}
