/*
  Copyright (c) 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net>
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

#include "respondd-common.h"

#include <libgluonutil.h>

#include <iwinfo.h>
#include <json-c/json.h>

#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include <sys/vfs.h>


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

static void count_iface_stations(size_t *wifi24, size_t *wifi5, const char *ifname) {
	const struct iwinfo_ops *iw = iwinfo_backend(ifname);
	if (!iw)
		return;

	int freq;
	if (iw->frequency(ifname, &freq) < 0)
		return;

	size_t *wifi;
	if (freq >= 2400 && freq < 2500)
		wifi = wifi24;
	else if (freq >= 5000 && freq < 6000)
		wifi = wifi5;
	else
		return;

	int len;
	char buf[IWINFO_BUFSIZE];
	if (iw->assoclist(ifname, buf, &len) < 0)
		return;

	struct iwinfo_assoclist_entry *entry;
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++) {
		if (entry->inactive > MAX_INACTIVITY)
			continue;

		(*wifi)++;
	}
}

static void count_stations(size_t *wifi24, size_t *wifi5, size_t *owe24, size_t owe5) {
	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		return;
	ctx->flags &= ~UCI_FLAG_STRICT;


	struct uci_package *p;
	if (uci_load(ctx, "wireless", &p))
		goto end;


	struct uci_element *e;
	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);
		if (strcmp(s->type, "wifi-iface"))
			continue;

		const char *network = uci_lookup_option_string(ctx, s, "network");
		if (!network || strcmp(network, "client"))
			continue;

		const char *mode = uci_lookup_option_string(ctx, s, "mode");
		if (!mode || strcmp(mode, "ap"))
			continue;

		const char *ifname = uci_lookup_option_string(ctx, s, "ifname");
		if (!ifname)
			continue;

		if (strstr(ifname, "owe") == ifname)
			count_iface_stations(owe24, owe5, ifname);

		count_iface_stations(wifi24, wifi5, ifname);
	}

 end:
	uci_free_context(ctx);
}

static struct json_object * get_clients(void) {
	size_t wifi24 = 0, wifi5 = 0, owe24 = 0, owe5 = 0;

	count_stations(&wifi24, &wifi5, &owe24, &owe5);

	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "wifi", json_object_new_int(wifi24 + wifi5));
	json_object_object_add(ret, "wifi24", json_object_new_int(wifi24));
	json_object_object_add(ret, "wifi5", json_object_new_int(wifi5));

	json_object_object_add(ret, "owe", json_object_new_int(owe24 + owe5));
	json_object_object_add(ret, "owe24", json_object_new_int(owe24));
	json_object_object_add(ret, "owe5", json_object_new_int(owe5));

	return ret;
}

struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "node_id", gluonutil_wrap_and_free_string(gluonutil_get_node_id()));

	json_object_object_add(ret, "time", get_time());
	json_object_object_add(ret, "rootfs_usage", get_rootfs_usage());
	json_object_object_add(ret, "memory", get_memory());
	json_object_object_add(ret, "stat", get_stat());

	json_object_object_add(ret, "clients", get_clients());

	add_uptime(ret);
	add_loadavg(ret);

	return ret;
}
