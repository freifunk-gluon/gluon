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
#include <uci.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

/**
 * Merges two JSON objects
 *
 * Both objects are consumed. On conflicts, object b will be preferred.
 */
static struct json_object * merge_json(struct json_object *a, struct json_object *b) {
	if (!json_object_is_type(a, json_type_object) || !json_object_is_type(b, json_type_object)) {
		json_object_put(a);
		return b;
	}

	json_object *m = json_object_new_object();

	json_object_object_foreach(a, key_a, val_a)
		json_object_object_add(m, key_a, json_object_get(val_a));
	json_object_put(a);

	json_object_object_foreach(b, key_b, val_b) {
		struct json_object *val_m;

		if (json_object_object_get_ex(m, key_b, &val_m))
			val_m = merge_json(json_object_get(val_m), json_object_get(val_b));
		else
			val_m = json_object_get(val_b);

		json_object_object_add(m, key_b, val_m);
	}
	json_object_put(b);

	return m;
}

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


bool gluonutil_get_node_prefix6(struct in6_addr *prefix) {
	struct json_object *site = gluonutil_load_site_config();
	if (!site)
		return false;

	struct json_object *node_prefix = NULL;
	if (!json_object_object_get_ex(site, "node_prefix6", &node_prefix)) {
		json_object_put(site);
		return false;
	}

	const char *str_prefix = json_object_get_string(node_prefix);
	if (!str_prefix) {
		json_object_put(site);
		return false;
	}

	char *prefix_addr = strndup(str_prefix, strchrnul(str_prefix, '/')-str_prefix);

	int ret = inet_pton(AF_INET6, prefix_addr, prefix);

	free(prefix_addr);
	json_object_put(site);

	if (ret != 1)
		return false;

	return true;
}



bool gluonutil_has_domains(void) {
	return (access("/lib/gluon/domains/", F_OK) == 0);
}

char * gluonutil_get_domain(void) {
	if (!gluonutil_has_domains())
		return NULL;

	char *ret = NULL;

	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		goto uci_fail;

	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (uci_load(ctx, "gluon", &p))
		goto uci_fail;

	struct uci_section *s = uci_lookup_section(ctx, p, "core");
	if (!s)
		goto uci_fail;

	const char *domain_code = uci_lookup_option_string(ctx, s, "domain");
	if (!domain_code)
		goto uci_fail;

	ret = strdup(domain_code);

uci_fail:
	if (ctx)
		uci_free_context(ctx);

	return ret;
}


struct json_object * gluonutil_load_site_config(void) {
	char *domain_code = NULL;
	struct json_object *site = NULL, *domain = NULL;

	site = json_object_from_file("/lib/gluon/site.json");
	if (!site)
		return NULL;

	if (!gluonutil_has_domains())
		return site;

	domain_code = gluonutil_get_domain();
	if (!domain_code)
		goto err;

	{
		const char *domain_path_fmt = "/lib/gluon/domains/%s.json";
		char domain_path[strlen(domain_path_fmt) + strlen(domain_code)];
		snprintf(domain_path, sizeof(domain_path), domain_path_fmt, domain_code);
		free(domain_code);

		domain = json_object_from_file(domain_path);
	}
	if (!domain)
		goto err;

	return merge_json(site, domain);

err:
	json_object_put(site);
	return NULL;
}
