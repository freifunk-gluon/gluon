/*
  Copyright (c) 2020, Leonardo Mörlein <me@irrelefant.net>
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


#include <respondd.h>

#include <json-c/json.h>
#include <libgluonutil.h>
#include <uci.h>

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <sys/un.h>

#include "libubus.h"

static struct json_object * stdout_read(const char *cmd, const char *skip, bool oneword) {
	FILE *f = popen(cmd, "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;
	size_t skiplen = strlen(skip);

	ssize_t read_chars = getline(&line, &len, f);

	pclose(f);

	if (read_chars < 1) {
		free(line);
		return NULL;
	}

	if (line[read_chars-1] == '\n')
		line[read_chars-1] = '\0';

	const char *content = line;
	if (strncmp(content, skip, skiplen) == 0)
		content += skiplen;

	if (oneword) {
		for (int i = 0; i < len; i++) {
			if (isspace(line[i])) {
				 line[i] = 0;
			}
		}
	}

	struct json_object *ret = gluonutil_wrap_string(content);
	free(line);
	return ret;
}

static struct json_object * get_wireguard_public_key(void) {
	return stdout_read("exec /lib/gluon/mesh-vpn/wireguard_pubkey.sh", "", false);
}

static struct json_object * get_wireguard_version(void) {
	return stdout_read("exec wg -v", "wireguard-tools ", true);
}

static bool wireguard_enabled(void) {
	bool enabled = true;

	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		goto disabled_nofree;
	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (uci_load(ctx, "network", &p))
		goto disabled;

	struct uci_section *s = uci_lookup_section(ctx, p, "wg_mesh");
	if (!s)
		goto disabled;

	const char *disabled_str = uci_lookup_option_string(ctx, s, "disabled");
	if (!disabled_str || !strcmp(disabled_str, "1"))
		enabled = false;

disabled:
	uci_free_context(ctx);

disabled_nofree:
	return enabled;
}

static bool get_pubkey_privacy(void) {
	bool ret = true;
	struct json_object *site = NULL;

	site = gluonutil_load_site_config();
	if (!site)
		goto end;

	struct json_object *mesh_vpn;
	if (!json_object_object_get_ex(site, "mesh_vpn", &mesh_vpn))
		goto end;

	struct json_object *pubkey_privacy;
	if (!json_object_object_get_ex(mesh_vpn, "pubkey_privacy", &pubkey_privacy))
		goto end;

	ret = json_object_get_boolean(pubkey_privacy);

end:
	json_object_put(site);

	return ret;
}

static struct json_object * get_wireguard(void) {
	bool wg_enabled = wireguard_enabled();

	struct json_object *ret = json_object_new_object();
	json_object_object_add(ret, "version", get_wireguard_version());
	json_object_object_add(ret, "enabled", json_object_new_boolean(wg_enabled));
	if (wg_enabled && !get_pubkey_privacy())
		json_object_object_add(ret, "public_key", get_wireguard_public_key());
	return ret;
}

static struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *software = json_object_new_object();
	json_object_object_add(software, "wireguard", get_wireguard());
	json_object_object_add(ret, "software", software);

	return ret;
}

static json_object *blobmsg_attr2json(struct blob_attr *attr, int type)
{
	int len = blobmsg_data_len(attr);
	struct blobmsg_data *data = blobmsg_data(attr);
	struct blob_attr *inner_attr;
	json_object *res = NULL;
	switch(type) {
		case BLOBMSG_TYPE_STRING:
			return gluonutil_wrap_string(blobmsg_get_string(attr));
		case BLOBMSG_TYPE_BOOL:
			return json_object_new_boolean(blobmsg_get_bool(attr));
		case BLOBMSG_TYPE_INT16:
			return json_object_new_double(blobmsg_get_u16(attr));
		case BLOBMSG_TYPE_INT32:
			return json_object_new_double(blobmsg_get_u32(attr));
		case BLOBMSG_TYPE_INT64:
			return json_object_new_double(blobmsg_get_u64(attr));
		case BLOBMSG_TYPE_DOUBLE:
			return json_object_new_double(blobmsg_get_double(attr));
		case BLOBMSG_TYPE_TABLE:
			res = json_object_new_object();
			__blob_for_each_attr(inner_attr, data, len) {
				json_object_object_add(res, blobmsg_name(inner_attr), blobmsg_attr2json(inner_attr, blobmsg_type(inner_attr)));
			};
			break;
		case BLOBMSG_TYPE_ARRAY:
			res = json_object_new_array();
			__blob_for_each_attr(inner_attr, data, len) {
				json_object_array_add(res, blobmsg_attr2json(inner_attr, blobmsg_type(inner_attr)));
			}
			break;
	}

	return res;
}

static void cb_wgpeerselector_vpn(struct ubus_request *req, int type, struct blob_attr *msg)
{
	json_object_object_add(req->priv, "mesh_vpn", blobmsg_attr2json(msg, type));
}

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();
	struct ubus_context *ctx = ubus_connect(NULL);
	uint32_t ubus_path_id;

	if (!ctx) {
		fprintf(stderr, "Error in gluon-mesh-vpn-wireguard.so: Failed to connect to ubus.\n");
		goto err;
	}

	if (ubus_lookup_id(ctx, "wgpeerselector.wg_mesh", &ubus_path_id)) {
		goto err;
	}

	ubus_invoke(ctx, ubus_path_id, "status", NULL, cb_wgpeerselector_vpn, ret, 1000);

err:
	if (ctx)
		ubus_free(ctx);
	return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{"statistics", respondd_provider_statistics},
	{}
};
