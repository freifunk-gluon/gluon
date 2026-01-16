/* SPDX-FileCopyrightText: 2016-2019, Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */

#include "respondd-common.h"

#include <libgluonutil.h>

#include <iwinfo.h>
#include <json-c/json.h>

#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
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

struct station_counts {
	size_t wifi24;
	size_t wifi5;
	size_t wifi6;
	size_t owe24;
	size_t owe5;
	size_t owe6;

	bool has_wifi24;
	bool has_wifi5;
	bool has_wifi6;
	bool has_owe24;
	bool has_owe5;
	bool has_owe6;
};

static void count_iface_stations(struct station_counts *s, const char *ifname) {
	if (!s)
		return;

	const struct iwinfo_ops *iw = iwinfo_backend(ifname);
	if (!iw)
		return;

	int freq;
	if (iw->frequency(ifname, &freq) < 0)
		return;

	size_t *wifi = NULL;
	size_t *owe = NULL;
	if (freq >= 2400 && freq < 2500) {
		wifi = &s->wifi24;
		owe = &s->owe24;
		s->has_wifi24 = true;
		if (strstr(ifname, "owe") == ifname)
			s->has_owe24 = true;
	} else if (freq >= 5000 && freq < 5900) {
		wifi = &s->wifi5;
		owe = &s->owe5;
		s->has_wifi5 = true;
		if (strstr(ifname, "owe") == ifname)
			s->has_owe5 = true;
	} else if (freq >= 5935 && freq < 7000) {
		wifi = &s->wifi6;
		owe = &s->owe6;
		s->has_wifi6 = true;
		if (strstr(ifname, "owe") == ifname)
			s->has_owe6 = true;
	} else {
		return;
	}

	int len;
	char buf[IWINFO_BUFSIZE];
	if (iw->assoclist(ifname, buf, &len) < 0)
		return;

	struct iwinfo_assoclist_entry *entry;
	for (entry = (struct iwinfo_assoclist_entry *)buf; (char*)(entry+1) <= buf + len; entry++) {
		if (entry->inactive > MAX_INACTIVITY)
			continue;

		(*wifi)++;

		if (strstr(ifname, "owe") == ifname && owe)
			(*owe)++;
	}
}

static struct station_counts *count_stations(void) {
	struct station_counts *counts = calloc(1, sizeof(*counts));
	struct uci_context *ctx = uci_alloc_context();
	if (!ctx)
		return counts;
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

		count_iface_stations(counts, ifname);
	}

end:
	uci_free_context(ctx);
	return counts;
}

static struct json_object * get_clients(void) {
	struct station_counts *stat_counts = count_stations();


	struct json_object *ret = json_object_new_object();

	json_object_object_add(ret, "wifi", json_object_new_int(stat_counts->wifi24 + stat_counts->wifi5 + stat_counts->wifi6));
	if (stat_counts->has_wifi24)
		json_object_object_add(ret, "wifi24", json_object_new_int(stat_counts->wifi24));
	if (stat_counts->has_wifi5)
		json_object_object_add(ret, "wifi5", json_object_new_int(stat_counts->wifi5));
	if (stat_counts->has_wifi6)
		json_object_object_add(ret, "wifi6", json_object_new_int(stat_counts->wifi6));

	if (stat_counts->has_owe24 || stat_counts->has_owe5 || stat_counts->has_owe6)
		json_object_object_add(ret, "owe", json_object_new_int(stat_counts->owe24 + stat_counts->owe5 + stat_counts->owe6));
	if (stat_counts->has_owe24)
		json_object_object_add(ret, "owe24", json_object_new_int(stat_counts->owe24));
	if (stat_counts->has_owe5)
		json_object_object_add(ret, "owe5", json_object_new_int(stat_counts->owe5));
	if (stat_counts->has_owe6)
		json_object_object_add(ret, "owe6", json_object_new_int(stat_counts->owe6));

	free(stat_counts);

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
