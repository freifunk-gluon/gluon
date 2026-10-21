/* SPDX-License-Identifier: BSD-2-Clause */

#include <unistd.h>
#include <time.h>

#include <sys/sysinfo.h>
#include <ucode/module.h>

static uc_value_t *uc_sysinfo(uc_vm_t *vm, size_t nargs) {
	uc_value_t *return_object, *load_array;
	double f_load = 1.f / (1 << SI_LOAD_SHIFT);
	struct sysinfo info;

	sysinfo(&info);
	return_object = ucv_object_new(vm);

	/* Uptime*/
	ucv_object_add(return_object, "uptime", ucv_uint64_new(info.uptime));

	/* Load averages */
	load_array = ucv_array_new(vm);
	for (int i = 0; i < 3; i++) {
		ucv_array_push(load_array, ucv_double_new(info.loads[i] * f_load));
	}
	ucv_object_add(return_object, "loads", load_array);

	/* Memory information */
#define ADD_MEMINFO_FIELD(name) ucv_object_add(return_object, #name, ucv_uint64_new(info.name))
	ADD_MEMINFO_FIELD(totalram);
	ADD_MEMINFO_FIELD(freeram);
	ADD_MEMINFO_FIELD(sharedram);
	ADD_MEMINFO_FIELD(bufferram);
	ADD_MEMINFO_FIELD(totalswap);
	ADD_MEMINFO_FIELD(freeswap);
#undef ADD_MEMINFO_FIELD

	/* Process information */
	ucv_object_add(return_object, "procs", ucv_int64_new(info.procs));

	/* Page information */
	ucv_object_add(return_object, "totalhigh", ucv_uint64_new(info.totalhigh));
	ucv_object_add(return_object, "freehigh", ucv_uint64_new(info.freehigh));
	ucv_object_add(return_object, "mem_unit", ucv_int64_new(info.mem_unit));

	return return_object;
}

static uc_value_t *uc_nproc(uc_vm_t *vm, size_t nargs) {
	return ucv_int64_new(sysconf(_SC_NPROCESSORS_ONLN));
}

static uc_value_t *uc_clock_monotonic(uc_vm_t *vm, size_t nargs) {
	struct timespec ts;
	uint64_t uptime_ms;

	clock_gettime(CLOCK_MONOTONIC, &ts);

	uptime_ms = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
	return ucv_uint64_new(uptime_ms);
}

static const uc_function_list_t global_fns[] = {
	{ "sysinfo",	uc_sysinfo },
	{ "nproc", 	uc_nproc },
	{ "get_clock_monotonic",	uc_clock_monotonic }, 
};

void uc_module_init(uc_vm_t *vm, uc_value_t *scope) {
	uc_function_list_register(scope, global_fns);
}
