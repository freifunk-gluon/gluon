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
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <uci.h>

/**
 * Merges two JSON objects
 *
 * On conflicts, object a will be preferred.
 *
 * Internally, this functions merges all entries from object a into object b,
 * so merging a small object a with a big object b is faster than vice-versa.
 */
static struct json_object * merge_json(struct json_object *a, struct json_object *b) {
	if (!json_object_is_type(a, json_type_object) || !json_object_is_type(b, json_type_object)) {
		json_object_put(b);
		return a;
	}

	json_object_object_foreach(a, key, val_a) {
		struct json_object *val_b;

		json_object_get(val_a);

		if (!json_object_object_get_ex(b, key, &val_b)) {
			json_object_object_add(b, key, val_a);
			continue;
		}

		json_object_get(val_b);

		json_object_object_add(b, key, merge_json(val_a, val_b));
	}

	json_object_put(a);
	return b;
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

char * get_selected_domain_code(struct json_object * base) {
	char * domain_path_fmt = "/lib/gluon/domains/%s.json";
	char domain_path[strlen(domain_path_fmt) + 256];
	const char * domain_code;

	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		goto uci_fail;

	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (uci_load(ctx, "gluon", &p))
		goto uci_fail;

	struct uci_section *s = uci_lookup_section(ctx, p, "system");
	if (!s)
		goto uci_fail;

	domain_code = uci_lookup_option_string(ctx, s, "domain_code");

	if (!domain_code)
		goto uci_fail;

	snprintf(domain_path, sizeof domain_path, domain_path_fmt, domain_code);

	if (access(domain_path, R_OK) != -1) {
		// ${domain_code}.conf exists and is accessible
		char * domain_code_cpy = strndup(domain_code, 256); // copy before free
		uci_free_context(ctx);
		return domain_code_cpy;
	}

uci_fail:
	if (ctx)
		uci_free_context(ctx);

	json_object * default_domain_code;

	// it's okay to pass base == NULL to json_object_object_get_ex()
	if (!json_object_object_get_ex(base, "default_domain_code", &default_domain_code))
		return NULL;

	domain_code = json_object_get_string(default_domain_code);

	if (!domain_code)
		return NULL;

	// the gluon build environment should ensure, that this filename exists,
	// but to be sure, we check here again.
	snprintf(domain_path, sizeof domain_path, domain_path_fmt, domain_code);

	if (access(domain_path, R_OK) == -1)
		return NULL;

	// create a copy so site could be freed before domain_code
	return strndup(domain_code, 256);
}

/**
 * Get selected domain code
 *
 * - If NULL is passed to the site parameter, internally only the base part
 *   (without domain config) is loaded, which is more efficient than calling
 *   gluonutil_load_site_config() for this job only. Nevertheless if you already
 *   have an instance of a site object then you should pass it here.
 * - Returned domain code string has to be freed after use
 * - Returns NULL in case of error
 * - If a domain code is returned, it's ensured that the corresponding config
 *   in /lib/gluon/domains/ exists.
 */
char * gluonutil_get_selected_domain_code(struct json_object * site) {
	if (site)
		// If the user already has allocated a whole site object, it makes no sense
		// to load the base object. Taking the site object (merged from domain and
		// base) should be fine here.
		return get_selected_domain_code(site);

	// load base
	struct json_object * base = json_object_from_file("/lib/gluon/site.json");

	if (!base)
		return NULL;

	return get_selected_domain_code(base);
}

struct json_object * gluonutil_load_site_config(void) {
	// load base
	struct json_object * base = json_object_from_file("/lib/gluon/site.json");

	if (!base)
		return NULL;

	// load domain
	char * domain_path_fmt = "/lib/gluon/domains/%s.json";
	char domain_path[strlen(domain_path_fmt) + 256];
	char * domain_code = get_selected_domain_code(base);

	if (!domain_code) {
		// something went horribly wrong here
		json_object_put(base); // free base
		return NULL;
	}

	snprintf(domain_path, sizeof domain_path, domain_path_fmt, domain_code);


	struct json_object * domain = json_object_from_file(domain_path);

	if (!domain) {
		json_object_put(base);
		return NULL;
	}

	json_object * aliases;

	// it's okay to pass base == NULL to json_object_object_get_ex()
	if (!json_object_object_get_ex(domain, "domain_aliases", &aliases))
		goto skip_name_replacement;

	json_object * aliased_domain_name;

	if (!json_object_object_get_ex(aliases, domain_code, &aliased_domain_name))
		goto skip_name_replacement;

	// freeing of old value is done inside json_object_object_add()
	json_object_object_add(domain, "domain_name", json_object_get(aliased_domain_name));

skip_name_replacement:

	free(domain_code);

	// finally merge them
	return merge_json(domain, base);
}
