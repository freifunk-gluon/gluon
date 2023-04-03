/* SPDX-FileCopyrightText: 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */

#include "respondd-common.h"

#include <libgluonutil.h>

#include <iwinfo.h>
#include <json-c/json.h>


static struct json_object * get_wifi_neighbours(const char *ifname) {
	const struct iwinfo_ops *iw = iwinfo_backend(ifname);
	if (!iw)
		return NULL;

	int len;
	char buf[IWINFO_BUFSIZE];
	if (iw->assoclist(ifname, buf, &len) < 0)
		return NULL;

	struct json_object *neighbours = json_object_new_object();

	struct iwinfo_assoclist_entry *entry;
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++) {
		if (entry->inactive > MAX_INACTIVITY)
			continue;

		struct json_object *obj = json_object_new_object();

		json_object_object_add(obj, "signal", json_object_new_int(entry->signal));
		json_object_object_add(obj, "noise", json_object_new_int(entry->noise));
		json_object_object_add(obj, "inactive", json_object_new_int(entry->inactive));

		char mac[18];
		snprintf(mac, sizeof(mac), "%02x:%02x:%02x:%02x:%02x:%02x",
				entry->mac[0], entry->mac[1], entry->mac[2],
				entry->mac[3], entry->mac[4], entry->mac[5]);

		json_object_object_add(neighbours, mac, obj);
	}

	struct json_object *ret = json_object_new_object();

	if (json_object_object_length(neighbours))
		json_object_object_add(ret, "neighbours", neighbours);
	else
		json_object_put(neighbours);

	return ret;
}

static struct json_object * get_wifi(void) {
	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		return NULL;

	ctx->flags &= ~UCI_FLAG_STRICT;

	struct json_object *ret = json_object_new_object();

	struct uci_package *p;
	if (uci_load(ctx, "wireless", &p))
		goto end;


	struct uci_element *e;
	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);
		if (strcmp(s->type, "wifi-iface"))
			continue;

		const char *proto = uci_lookup_option_string(ctx, s, "mode");
		if (!proto || strcmp(proto, "mesh"))
			continue;

		const char *ifname = uci_lookup_option_string(ctx, s, "ifname");
		if (!ifname)
			continue;

		char *ifaddr = gluonutil_get_interface_address(ifname);
		if (!ifaddr)
			continue;

		struct json_object *neighbours = get_wifi_neighbours(ifname);
		if (neighbours)
			json_object_object_add(ret, ifaddr, neighbours);

		free(ifaddr);
	}

end:
	uci_free_context(ctx);
	return ret;
}

struct json_object * respondd_provider_neighbours(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));

	struct json_object *wifi = get_wifi();
	if (wifi)
		json_object_object_add(ret, "wifi", wifi);


	return ret;
}
