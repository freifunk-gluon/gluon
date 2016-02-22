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
#include <libplatforminfo.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/utsname.h>
#include <sys/vfs.h>


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

static struct json_object * get_hostname(void) {
	struct utsname utsname;

	if (uname(&utsname))
		return NULL;

	return gluonutil_wrap_string(utsname.nodename);
}

static struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));
	json_object_object_add(ret, "hostname", get_hostname());

	struct json_object *hardware = json_object_new_object();
	json_object_object_add(hardware, "model", json_object_new_string(platforminfo_get_model()));
	json_object_object_add(hardware, "nproc", json_object_new_int(sysconf(_SC_NPROCESSORS_ONLN)));
	json_object_object_add(ret, "hardware", hardware);

	struct json_object *network = json_object_new_object();
	json_object_object_add(network, "mac", gluonutil_wrap_and_free_string(gluonutil_get_sysconfig("primary_mac")));
	json_object_object_add(ret, "network", network);

	struct json_object *software = json_object_new_object();
	struct json_object *software_firmware = json_object_new_object();
	json_object_object_add(software_firmware, "base", gluon_version());
	json_object_object_add(software_firmware, "release", gluonutil_wrap_and_free_string(gluonutil_read_line("/lib/gluon/release")));
	json_object_object_add(software, "firmware", software_firmware);
	json_object_object_add(ret, "software", software);

	struct json_object *system = json_object_new_object();
	json_object_object_add(system, "site_code", get_site_code());
	json_object_object_add(ret, "system", system);

	return ret;
}


static void add_uptime(struct json_object *obj) {
	FILE *f = fopen("/proc/uptime", "r");
	if (!f)
		return;

	double uptime, idletime;
	if (fscanf(f, "%lf %lf", &uptime, &idletime) == 2) {
		json_object_object_add(obj, "uptime", json_object_new_double(uptime));
		json_object_object_add(obj, "idletime", json_object_new_double(idletime));
	}

	fclose(f);
}

static void add_loadavg(struct json_object *obj) {
	FILE *f = fopen("/proc/loadavg", "r");
	if (!f)
		return;

	double loadavg;
	unsigned proc_running, proc_total;
	if (fscanf(f, "%lf %*f %*f %u/%u", &loadavg, &proc_running, &proc_total) == 3) {
		json_object_object_add(obj, "loadavg", json_object_new_double(loadavg));

		struct json_object *processes = json_object_new_object();
		json_object_object_add(processes, "running", json_object_new_int(proc_running));
		json_object_object_add(processes, "total", json_object_new_int(proc_total));
		json_object_object_add(obj, "processes", processes);
	}

	fclose(f);
}

static struct json_object * get_memory(void) {
	FILE *f = fopen("/proc/meminfo", "r");
	if (!f)
		return NULL;

	struct json_object *ret = json_object_new_object();

	char *line = NULL;
	size_t len = 0;

	while (getline(&line, &len, f) >= 0) {
		char label[32];
		unsigned value;

		if (sscanf(line, "%31[^:]: %u", label, &value) != 2)
			continue;

		if (!strcmp(label, "MemTotal"))
			json_object_object_add(ret, "total", json_object_new_int(value));
		else if (!strcmp(label, "MemFree"))
			json_object_object_add(ret, "free", json_object_new_int(value));
		else if (!strcmp(label, "Buffers"))
			json_object_object_add(ret, "buffers", json_object_new_int(value));
		else if (!strcmp(label, "Cached"))
			json_object_object_add(ret, "cached", json_object_new_int(value));
	}

	free(line);
	fclose(f);

	return ret;
}

static struct json_object * get_rootfs_usage(void) {
	struct statfs s;
	if (statfs("/", &s))
		return NULL;

	return json_object_new_double(1 - (double)s.f_bfree / s.f_blocks);
}

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));

	json_object_object_add(ret, "rootfs_usage", get_rootfs_usage());
	json_object_object_add(ret, "memory", get_memory());

	add_uptime(ret);
	add_loadavg(ret);

	return ret;
}


static struct json_object * respondd_provider_neighbours(void) {
	struct json_object *ret = json_object_new_object();
	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));
	return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{"statistics", respondd_provider_statistics},
	{"neighbours", respondd_provider_neighbours},
	{}
};
