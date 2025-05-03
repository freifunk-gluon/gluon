/* SPDX-FileCopyrightText: 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */

#include "respondd-common.h"

#include <libgluonutil.h>
#include <libplatforminfo.h>

#include <json-c/json.h>
#include <uci.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>


static struct json_object * gluon_version(void) {
	char *version = gluonutil_read_line("/lib/gluon/gluon-version");
	if (!version)
		return NULL;

	char full_version[6 + strlen(version) + 1];
	snprintf(full_version, sizeof(full_version), "gluon-%s", version);

	free(version);


	return json_object_new_string(full_version);
}

static struct json_object * get_site_code(void) {
	struct json_object *site = gluonutil_load_site_config();
	if (!site)
		return NULL;

	struct json_object *ret = NULL;
	json_object_object_get_ex(site, "site_code", &ret);
	if (ret)
		json_object_get(ret);

	json_object_put(site);
	return ret;
}

static struct json_object * get_primary_domain_code(void) {
	return gluonutil_wrap_and_free_string(gluonutil_get_primary_domain());
}

static struct json_object * get_domain_code(void) {
	return gluonutil_wrap_and_free_string(gluonutil_get_domain());
}

static struct json_object * get_hostname(void) {
	struct json_object *ret = NULL;

	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		return NULL;
	ctx->flags &= ~UCI_FLAG_STRICT;

	char section[] = "system.@system[0]";
	struct uci_ptr ptr;
	if (uci_lookup_ptr(ctx, &ptr, section, true))
		goto error;

	struct uci_section *s = ptr.s;

	const char *hostname = uci_lookup_option_string(ctx, s, "pretty_hostname");

	if (!hostname)
		hostname = uci_lookup_option_string(ctx, s, "hostname");

	ret = gluonutil_wrap_string(hostname);

error:
	uci_free_context(ctx);

	return ret;
}

struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));
	json_object_object_add(ret, "hostname", get_hostname());

	struct json_object *hardware = json_object_new_object();

	const char *model = platforminfo_get_model();
	if (model)
		json_object_object_add(hardware, "model", json_object_new_string(model));

	json_object_object_add(hardware, "nproc", json_object_new_int(sysconf(_SC_NPROCESSORS_ONLN)));
	json_object_object_add(ret, "hardware", hardware);

	struct json_object *network = json_object_new_object();
	json_object_object_add(network, "mac", gluonutil_wrap_and_free_string(gluonutil_get_sysconfig("primary_mac")));
	json_object_object_add(ret, "network", network);

	struct json_object *software = json_object_new_object();
	struct json_object *software_firmware = json_object_new_object();
	json_object_object_add(software_firmware, "base", gluon_version());
	json_object_object_add(software_firmware, "release", gluonutil_wrap_and_free_string(gluonutil_read_line("/lib/gluon/release")));
	json_object_object_add(software_firmware, "target", gluonutil_wrap_string(platforminfo_get_target()));
	json_object_object_add(software_firmware, "subtarget", gluonutil_wrap_string(platforminfo_get_subtarget()));
	json_object_object_add(software_firmware, "image_name", gluonutil_wrap_string(platforminfo_get_image_name()));
	json_object_object_add(software, "firmware", software_firmware);
	json_object_object_add(ret, "software", software);

	struct json_object *system = json_object_new_object();
	json_object_object_add(system, "site_code", get_site_code());
	if (gluonutil_has_domains()) {
		json_object_object_add(system, "domain_code", get_domain_code());
		json_object_object_add(system, "primary_domain_code", get_primary_domain_code());
	}
	json_object_object_add(ret, "system", system);

	return ret;
}
