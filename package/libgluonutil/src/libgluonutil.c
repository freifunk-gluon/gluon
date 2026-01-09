/* SPDX-FileCopyrightText: 2016 Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */


#include "libgluonutil.h"

#include <json-c/json.h>
#include <uci.h>

#include <arpa/inet.h>

#include <errno.h>
#include <glob.h>
#include <libgen.h>
#include <limits.h>
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

void gluonutil_get_interface_lower(char out[IF_NAMESIZE], const char *ifname) {
	strncpy(out, ifname, IF_NAMESIZE-1);
	out[IF_NAMESIZE-1] = 0;

	const char *format = "/sys/class/net/%s/lower_*";
	char pattern[strlen(format) + IF_NAMESIZE];

	while (true) {
		snprintf(pattern, sizeof(pattern), format, out);
		size_t pattern_len = strlen(pattern);

		glob_t lower;
		if (glob(pattern, GLOB_NOSORT, NULL, &lower) != 0)
			break;

		strncpy(out, lower.gl_pathv[0] + pattern_len - 1, IF_NAMESIZE-1);

		globfree(&lower);
	}
}

enum gluonutil_interface_type lookup_interface_type(const char *devtype) {
	if (strcmp(devtype, "wlan") == 0)
		return GLUONUTIL_INTERFACE_TYPE_WIRELESS;

	if (strcmp(devtype, "l2tpeth") == 0 || strcmp(devtype, "wireguard") == 0)
		return GLUONUTIL_INTERFACE_TYPE_TUNNEL;

	/* Regular wired interfaces do not set DEVTYPE, so if this point is
	 * reached, we have something different */
	return GLUONUTIL_INTERFACE_TYPE_UNKNOWN;
}

enum gluonutil_interface_type gluonutil_get_interface_type(const char *ifname) {
	const char *pattern = "/sys/class/net/%s/%s";

	/* Default to wired type when no DEVTYPE is set */
	enum gluonutil_interface_type ret = GLUONUTIL_INTERFACE_TYPE_WIRED;
	char *line = NULL, path[PATH_MAX];
	size_t buflen = 0;
	ssize_t len;
	FILE *f;

	snprintf(path, sizeof(path), pattern, ifname, "tun_flags");
	if (access(path, F_OK) == 0)
		return GLUONUTIL_INTERFACE_TYPE_TUNNEL;

	snprintf(path, sizeof(path), pattern, ifname, "uevent");
	f = fopen(path, "r");
	if (!f)
		return GLUONUTIL_INTERFACE_TYPE_UNKNOWN;

	while ((len = getline(&line, &buflen, f)) >= 0) {
		if (len == 0)
			continue;

		if (line[len-1] == '\n')
			line[len-1] = '\0';

		if (strncmp(line, "DEVTYPE=", 8) == 0) {
			ret = lookup_interface_type(line+8);
			break;
		}
	}
	free(line);

	fclose(f);
	return ret;
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

char * gluonutil_get_primary_domain(void) {
	if (!gluonutil_has_domains())
		return NULL;

	char *domain_code = gluonutil_get_domain();
	if (!domain_code)
		return NULL;

	const char *domain_path_fmt = "/lib/gluon/domains/%s.json";
	char domain_path[strlen(domain_path_fmt) + strlen(domain_code)];
	snprintf(domain_path, sizeof(domain_path), domain_path_fmt, domain_code);

	char primary_domain_path[PATH_MAX+1];
	char *primary_domain_code;
	ssize_t len = readlink(domain_path, primary_domain_path, PATH_MAX);
	if (len < 0) {
		// EINVAL = file is not a symlink = the domain itself is the primary domain
		if (errno != EINVAL) {
			free(domain_code);
			return NULL;
		}

		return domain_code;
	}

	free(domain_code);

	primary_domain_path[len] = '\0';
	primary_domain_code = basename(primary_domain_path);

	char *ext_begin = strrchr(primary_domain_code, '.');
	if (!ext_begin)
		return NULL;

	// strip .json from filename
	*ext_begin = '\0';
	return strdup(primary_domain_code);
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
