/* SPDX-License-Identifier: BSD-2-Clause */

#include <libplatforminfo.h>

#include <ucode/module.h>

static uc_value_t *uc_board(uc_vm_t *vm, size_t nargs) {
	uc_value_t *return_object;

	return_object = ucv_object_new(vm);

	ucv_object_add(return_object, "model", ucv_string_new(platforminfo_get_model()));
	ucv_object_add(return_object, "target", ucv_string_new(platforminfo_get_target()));
	ucv_object_add(return_object, "subtarget", ucv_string_new(platforminfo_get_subtarget()));	
	ucv_object_add(return_object, "board_name", ucv_string_new(platforminfo_get_board_name()));
	ucv_object_add(return_object, "image_name", ucv_string_new(platforminfo_get_image_name()));

	return return_object;
}

static const uc_function_list_t global_fns[] = {
	{ "board",	uc_board },
};

void uc_module_init(uc_vm_t *vm, uc_value_t *scope) {
	uc_function_list_register(scope, global_fns);
}