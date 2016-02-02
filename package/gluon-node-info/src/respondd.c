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


#include <respondd.h>

#include <json-c/json.h>
#include <libgluonutil.h>

#include <uci.h>

#include <stdlib.h>
#include <string.h>


static struct uci_section * get_first_section(struct uci_package *p, const char *type) {
	struct uci_element *e;
	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);
		if (!strcmp(s->type, type))
			return s;
	}

	return NULL;
}

static const char * get_first_option(struct uci_context *ctx, struct uci_package *p, const char *type, const char *option) {
	struct uci_section *s = get_first_section(p, type);
	if (s)
		return uci_lookup_option_string(ctx, s, option);
	else
		return NULL;
}

static struct json_object * get_number(struct uci_context *ctx, struct uci_section *s, const char *name) {
	const char *val = uci_lookup_option_string(ctx, s, name);
	if (!val || !*val)
		return NULL;

	char *end;
	double d = strtod(val, &end);
	if (*end)
		return NULL;

	return json_object_new_double(d);
}

static struct json_object * get_location(struct uci_context *ctx, struct uci_package *p) {
	struct uci_section *s = get_first_section(p, "location");
	if (!s)
		return NULL;

	const char *share = uci_lookup_option_string(ctx, s, "share_location");
	if (!share || strcmp(share, "1"))
		return NULL;

	struct json_object *ret = json_object_new_object();

	struct json_object *latitude = get_number(ctx, s, "latitude");
	if (latitude)
		json_object_object_add(ret, "latitude", latitude);

	struct json_object *longitude = get_number(ctx, s, "longitude");
	if (longitude)
		json_object_object_add(ret, "longitude", longitude);

	struct json_object *altitude = get_number(ctx, s, "altitude");
	if (altitude)
		json_object_object_add(ret, "altitude", altitude);

	return ret;
}

static struct json_object * get_owner(struct uci_context *ctx, struct uci_package *p) {
	const char *contact = get_first_option(ctx, p, "owner", "contact");
	if (!contact || !*contact)
		return NULL;

	struct json_object *ret = json_object_new_object();
	json_object_object_add(ret, "contact", gluonutil_wrap_string(contact));
	return ret;
}

static struct json_object * get_system(struct uci_context *ctx, struct uci_package *p) {
	struct json_object *ret = json_object_new_object();

	const char *role = get_first_option(ctx, p, "system", "role");
	if (role && *role)
		json_object_object_add(ret, "role", gluonutil_wrap_string(role));

	return ret;
}

static struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	struct uci_context *ctx = uci_alloc_context();
	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (!uci_load(ctx, "gluon-node-info", &p)) {
		struct json_object *location = get_location(ctx, p);
		if (location)
			json_object_object_add(ret, "location", location);

		struct json_object *owner = get_owner(ctx, p);
		if (owner)
			json_object_object_add(ret, "owner", owner);

		json_object_object_add(ret, "system", get_system(ctx, p));
	}

	uci_free_context(ctx);

	return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{}
};
