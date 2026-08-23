#include <respondd.h>

#include <json-c/json.h>
#include <libgluonutil.h>
#include <stdio.h>
#include <string.h>

// Matches the 'ether saddr != <mac>' expression the daemon installs and
// returns <mac>, or NULL for any other expression.
static const char * match_ether_saddr_neq(struct json_object *expr) {
	struct json_object *match, *left, *payload, *op, *protocol, *field, *right;

	if (!json_object_object_get_ex(expr, "match", &match))
		return NULL;

	if (!json_object_object_get_ex(match, "op", &op) ||
			strcmp(json_object_get_string(op), "!=") != 0)
		return NULL;

	if (!json_object_object_get_ex(match, "left", &left) ||
			!json_object_object_get_ex(left, "payload", &payload))
		return NULL;

	if (!json_object_object_get_ex(payload, "protocol", &protocol) ||
			strcmp(json_object_get_string(protocol), "ether") != 0)
		return NULL;

	if (!json_object_object_get_ex(payload, "field", &field) ||
			strcmp(json_object_get_string(field), "saddr") != 0)
		return NULL;

	if (!json_object_object_get_ex(match, "right", &right) ||
			!json_object_is_type(right, json_type_string))
		return NULL;

	return json_object_get_string(right);
}

static const char * find_filtered_mac(struct json_object *ruleset) {
	struct json_object *nftables;
	size_t i;

	if (!json_object_object_get_ex(ruleset, "nftables", &nftables) ||
			!json_object_is_type(nftables, json_type_array))
		return NULL;

	for (i = 0; i < json_object_array_length(nftables); i++) {
		struct json_object *rule, *expr;
		size_t j;

		if (!json_object_object_get_ex(json_object_array_get_idx(nftables, i), "rule", &rule))
			continue;

		if (!json_object_object_get_ex(rule, "expr", &expr) ||
				!json_object_is_type(expr, json_type_array))
			continue;

		for (j = 0; j < json_object_array_length(expr); j++) {
			const char *mac = match_ether_saddr_neq(json_object_array_get_idx(expr, j));
			if (mac)
				return mac;
		}
	}

	return NULL;
}

static struct json_object * get_radv_filter(void) {
	FILE *f = popen("exec nft -j list chain bridge gluon radv_filter", "r");
	struct json_object *ruleset, *ret = NULL;
	const char *mac;

	if (!f)
		return NULL;

	ruleset = json_object_from_fd(fileno(f));
	pclose(f);

	if (!ruleset)
		return NULL;

	mac = find_filtered_mac(ruleset);
	if (mac)
		ret = gluonutil_wrap_string(mac);

	json_object_put(ruleset);

	return ret;
}

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "gateway6", get_radv_filter());

	return ret;
}

const struct respondd_provider_info respondd_providers[] = {
	{"statistics", respondd_provider_statistics},
	{}
};
