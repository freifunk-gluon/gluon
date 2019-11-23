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
#include <uci.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <inttypes.h>

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

static struct json_object * respondd_provider_nodeinfo(void) {
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
	json_object_object_add(software, "firmware", software_firmware);
	json_object_object_add(ret, "software", software);

	struct json_object *system = json_object_new_object();
	json_object_object_add(system, "site_code", get_site_code());
	if (gluonutil_has_domains())
		json_object_object_add(system, "domain_code", get_domain_code());
	json_object_object_add(ret, "system", system);

	return ret;
}


static void add_uptime(struct json_object *obj) {
	FILE *f = fopen("/proc/uptime", "r");
	struct json_object* jso;
	if (!f)
		return;

	double uptime, idletime;
	if (fscanf(f, "%lf %lf", &uptime, &idletime) == 2) {
		jso = json_object_new_double(uptime);
		json_object_set_serializer(jso, json_object_double_to_json_string, "%.2f", NULL);
		json_object_object_add(obj, "uptime", jso);
		jso = json_object_new_double(idletime);
		json_object_set_serializer(jso, json_object_double_to_json_string, "%.2f", NULL);
		json_object_object_add(obj, "idletime", jso);
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
		struct json_object *jso = json_object_new_double(loadavg);
		json_object_set_serializer(jso, json_object_double_to_json_string, "%.2f", NULL);
		json_object_object_add(obj, "loadavg", jso);

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
		else if (!strcmp(label, "MemAvailable"))
			json_object_object_add(ret, "available", json_object_new_int(value));
		else if (!strcmp(label, "Buffers"))
			json_object_object_add(ret, "buffers", json_object_new_int(value));
		else if (!strcmp(label, "Cached"))
			json_object_object_add(ret, "cached", json_object_new_int(value));
	}

	free(line);
	fclose(f);

	return ret;
}

static struct json_object * get_stat(void) {
	FILE *f = fopen("/proc/stat", "r");
	if (!f)
		return NULL;

	struct json_object *stat = json_object_new_object();
	struct json_object *ret = NULL;

	char *line = NULL;
	size_t len = 0;

	while (getline(&line, &len, f) >= 0) {
		char label[32];

		if (sscanf(line, "%31s", label) != 1){
			goto invalid_stat_format;
		}

		if (!strcmp(label, "cpu")) {
			int64_t user, nice, system, idle, iowait, irq, softirq;
			if (sscanf(line, "%*s %"SCNd64" %"SCNd64" %"SCNd64" %"SCNd64" %"SCNd64" %"SCNd64" %"SCNd64,
			          &user, &nice, &system, &idle, &iowait, &irq, &softirq) != 7)
				goto invalid_stat_format;

			struct json_object *cpu = json_object_new_object();

			json_object_object_add(cpu, "user", json_object_new_int64(user));
			json_object_object_add(cpu, "nice", json_object_new_int64(nice));
			json_object_object_add(cpu, "system", json_object_new_int64(system));
			json_object_object_add(cpu, "idle", json_object_new_int64(idle));
			json_object_object_add(cpu, "iowait", json_object_new_int64(iowait));
			json_object_object_add(cpu, "irq", json_object_new_int64(irq));
			json_object_object_add(cpu, "softirq", json_object_new_int64(softirq));

			json_object_object_add(stat, "cpu", cpu);
		} else if (!strcmp(label, "ctxt")) {
			int64_t ctxt;
			if (sscanf(line, "%*s %"SCNd64, &ctxt) != 1)
				goto invalid_stat_format;

			json_object_object_add(stat, "ctxt", json_object_new_int64(ctxt));
		} else if (!strcmp(label, "intr")) {
			int64_t total_intr;
			if (sscanf(line, "%*s %"SCNd64, &total_intr) != 1)
				goto invalid_stat_format;

			json_object_object_add(stat, "intr", json_object_new_int64(total_intr));
		} else if (!strcmp(label, "softirq")) {
			int64_t total_softirq;
			if (sscanf(line, "%*s %"SCNd64, &total_softirq) != 1)
				goto invalid_stat_format;

			json_object_object_add(stat, "softirq", json_object_new_int64(total_softirq));
		} else if (!strcmp(label, "processes")) {
			int64_t processes;
			if (sscanf(line, "%*s %"SCNd64, &processes) != 1)
				goto invalid_stat_format;

			json_object_object_add(stat, "processes", json_object_new_int64(processes));
		}

	}

	ret = stat;

invalid_stat_format:
	if (!ret)
		json_object_put(stat);

	free(line);
	fclose(f);

	return ret;
}


static struct json_object * get_rootfs_usage(void) {
	struct statfs s;
	if (statfs("/", &s))
		return NULL;

	struct json_object *jso = json_object_new_double(1 - (double)s.f_bfree / s.f_blocks);
	json_object_set_serializer(jso, json_object_double_to_json_string, "%.4f", NULL);
	return jso;
}

static struct json_object * get_time(void) {
	struct timespec now;

	if (clock_gettime(CLOCK_REALTIME, &now) != 0)
		return NULL;

	return json_object_new_int64(now.tv_sec);
}

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));

	json_object *time = get_time();
	if (time != NULL)
		json_object_object_add(ret, "time", time);

	json_object_object_add(ret, "rootfs_usage", get_rootfs_usage());
	json_object_object_add(ret, "memory", get_memory());
	json_object_object_add(ret, "stat", get_stat());

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
