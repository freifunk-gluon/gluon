/* SPDX-License-Identifier: BSD-2-Clause */

#include <libgluonutil.h>
#include <ucode/module.h>

#include <json-c/json.h>

#include <arpa/inet.h>

static uc_value_t *uc_wrap_and_free_string(char *val) {
	uc_value_t *ret;

	if (!val)
		return NULL;

	ret = ucv_string_new(val);
	free(val);

	return ret;
}

static uc_value_t *uc_get_node_id(uc_vm_t *vm, size_t nargs) {
	char *val = gluonutil_get_node_id();
	return uc_wrap_and_free_string(val);
}

static uc_value_t *uc_get_domain(uc_vm_t *vm, size_t nargs) {
	char *val = gluonutil_get_domain();
	return uc_wrap_and_free_string(val);
}

static uc_value_t *uc_get_primary_domain(uc_vm_t *vm, size_t nargs) {
	char *val = gluonutil_get_primary_domain();
	return uc_wrap_and_free_string(val);
}

static uc_value_t *uc_get_site_config(uc_vm_t *vm, size_t nargs) {
	uc_value_t *ret;
	struct json_object *val = gluonutil_load_site_config();
	if (!val)
		return NULL;

	ret = ucv_from_json(vm, val);
	json_object_put(val);
	return ret;
}

static const char *interface_type_strings(enum gluonutil_interface_type if_type) {
	switch (if_type) {
	case GLUONUTIL_INTERFACE_TYPE_WIRED:
		return "wan";
	case GLUONUTIL_INTERFACE_TYPE_WIRELESS:
		return "lan";
	case GLUONUTIL_INTERFACE_TYPE_TUNNEL:
		return "wireless";
	default:
		return "unknown";
	}
}

static uc_value_t *uc_get_interface_type(uc_vm_t *vm, size_t nargs) {
	enum gluonutil_interface_type if_type;
	uc_value_t *ifname_uc;

	if (nargs < 1)
		return NULL;
	
	ifname_uc = uc_fn_arg(0);
	if (ucv_type(ifname_uc) != UC_STRING)
		return NULL;

	if_type = gluonutil_get_interface_type(ucv_string_get(ifname_uc));
	return ucv_string_new(interface_type_strings(if_type));
}

static uc_value_t *uc_get_interface_lower(uc_vm_t *vm, size_t nargs) {
	uc_value_t *ifname_uc;
	char out[IF_NAMESIZE];

	if (nargs < 1)
		return NULL;

	ifname_uc = uc_fn_arg(0);
	if (ucv_type(ifname_uc) != UC_STRING)
		return NULL;

	gluonutil_get_interface_lower(out, ucv_string_get(ifname_uc));
	return ucv_string_new(out);
}

static uc_value_t *uc_get_interface_address(uc_vm_t *vm, size_t nargs) {
	uc_value_t *ifname_uc;

	if (nargs < 1)
		return NULL;

	ifname_uc = uc_fn_arg(0);
	if (ucv_type(ifname_uc) != UC_STRING)
		return NULL;

	return ucv_string_new(gluonutil_get_interface_address(ucv_string_get(ifname_uc)));
}

static uc_value_t *uc_get_node_prefix6(uc_vm_t *vm, size_t nargs) {
	struct in6_addr prefix;

	if (!gluonutil_get_node_prefix6(&prefix))
		return NULL;

	char buf[INET6_ADDRSTRLEN];
	inet_ntop(AF_INET6, &prefix, buf, sizeof(buf));
	return ucv_string_new(buf);
}

static uc_value_t *uc_get_sysconfig(uc_vm_t *vm, size_t nargs) {
	uc_value_t *key;
	char *val;

	if (nargs < 1)
		return NULL;

	key = uc_fn_arg(0);
	if (ucv_type(key) != UC_STRING)
		return NULL;

	val = gluonutil_get_sysconfig(ucv_string_get(key));
	if (!val)
		return NULL;

	return uc_wrap_and_free_string(val);
}

static uc_value_t *uc_has_domains(uc_vm_t *vm, size_t nargs) {
	return ucv_boolean_new(gluonutil_has_domains());
}

static const uc_function_list_t global_fns[] = {
	{ "get_node_id", uc_get_node_id },
	{ "get_domain", uc_get_domain },
	{ "get_primary_domain", uc_get_primary_domain },
	{ "get_site_config", uc_get_site_config },
	{ "get_interface_type", uc_get_interface_type },
	{ "get_interface_lower", uc_get_interface_lower },
	{ "get_interface_address", uc_get_interface_address },
	{ "get_node_prefix6", uc_get_node_prefix6 },
	{ "get_sysconfig", uc_get_sysconfig },
	{ "has_domains", uc_has_domains }
};

void uc_module_init(uc_vm_t *vm, uc_value_t *scope) {
	uc_function_list_register(scope, global_fns);
}