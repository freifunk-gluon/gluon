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

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <sys/un.h>


static struct json_object * get_peer_groups(struct json_object *groups, struct json_object *peers);

static struct json_object * get_fastd_version(void) {
	FILE *f = popen("exec fastd -v", "r");
	if (!f)
		return NULL;

	char *line = NULL;
	size_t len = 0;

	ssize_t r = getline(&line, &len, f);

	pclose(f);

	if (r >= 0) {
		len = strlen(line); /* The len given by getline is the buffer size, not the string length */

		if (len && line[len-1] == '\n')
			line[len-1] = 0;
	}
	else {
		free(line);
		line = NULL;
	}

	const char *version = line;
	if (strncmp(version, "fastd ", 6) == 0)
		version += 6;

	struct json_object *ret = gluonutil_wrap_string(version);
	free(line);
	return ret;
}

static struct json_object * get_fastd(void) {
	bool enabled = false;

	struct uci_context *ctx = uci_alloc_context();
	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (uci_load(ctx, "fastd", &p))
		goto disabled;

	struct uci_section *s = uci_lookup_section(ctx, p, "mesh_vpn");
	if (!s)
		goto disabled;

	const char *enabled_str = uci_lookup_option_string(ctx, s, "enabled");
	if (!enabled_str || !strcmp(enabled_str, "1"))
		enabled = true;

 disabled:

	uci_free_context(ctx);

	struct json_object *ret = json_object_new_object();
	json_object_object_add(ret, "version", get_fastd_version());
	json_object_object_add(ret, "enabled", json_object_new_boolean(enabled));
	return ret;
}

static struct json_object * respondd_provider_nodeinfo(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *software = json_object_new_object();
	json_object_object_add(software, "fastd", get_fastd());
	json_object_object_add(ret, "software", software);

	return ret;
}


static const char * get_status_socket(struct uci_context *ctx, struct uci_section *s) {
	return uci_lookup_option_string(ctx, s, "status_socket");
}

static struct json_object * read_status(struct uci_context *ctx, struct uci_section *s) {
	const char *path = get_status_socket(ctx, s);

	size_t addrlen = strlen(path);

	/* Allocate enough space for arbitrary-length paths */
	char addrbuf[offsetof(struct sockaddr_un, sun_path) + addrlen + 1];
	memset(addrbuf, 0, sizeof(addrbuf));

	struct sockaddr_un *addr = (struct sockaddr_un *)addrbuf;
	addr->sun_family = AF_UNIX;
	memcpy(addr->sun_path, path, addrlen+1);

	int fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0)
		return NULL;

	if (connect(fd, (struct sockaddr*)addr, sizeof(addrbuf)) < 0) {
		close(fd);
		return NULL;
	}

	struct json_object *ret = NULL;
	struct json_tokener *tok = json_tokener_new();

	do {
		char buf[1024];
		size_t len = read(fd, buf, sizeof(buf));
		if (len <= 0)
			break;

		ret = json_tokener_parse_ex(tok, buf, len);
	} while (!ret && json_tokener_get_error(tok) == json_tokener_continue);

	json_tokener_free(tok);
	close(fd);
	return ret;
}

static struct json_object * get_status(void) {
	struct json_object *ret = NULL;

	struct uci_context *ctx = uci_alloc_context();
	ctx->flags &= ~UCI_FLAG_STRICT;

	struct uci_package *p;
	if (!uci_load(ctx, "fastd", &p)) {
		struct uci_section *s = uci_lookup_section(ctx, p, "mesh_vpn");

		if (s)
			ret = read_status(ctx, s);
	}

	uci_free_context(ctx);

	return ret;
}

static bool get_peer_connection(struct json_object **ret, struct json_object *config, struct json_object *peers) {
	struct json_object *key_object;
	if (!json_object_object_get_ex(config, "key", &key_object))
		return false;

	const char *key = json_object_get_string(key_object);
	if (!key)
		return false;

	struct json_object *peer, *connection, *established;
	if (!json_object_object_get_ex(peers, key, &peer) ||
	    !json_object_object_get_ex(peer, "connection", &connection))
		return false;

	if (json_object_object_get_ex(connection, "established", &established)) {
		int64_t established_time = json_object_get_int64(established);

		*ret = json_object_new_object();
		json_object_object_add(*ret, "established", json_object_new_double(established_time/1000.0));
	}
	else {
		*ret = NULL;
	}

	return true;
}

static struct json_object * get_peer_group(struct json_object *config, struct json_object *peers) {
	struct json_object *ret = json_object_new_object();

	struct json_object *config_peers;
	if (json_object_object_get_ex(config, "peers", &config_peers) &&
	    json_object_is_type(config_peers, json_type_object)) {
		struct json_object *ret_peers = json_object_new_object();

		json_object_object_foreach(config_peers, peername, peerconfig) {
			struct json_object *obj;
			if (get_peer_connection(&obj, peerconfig, peers))
				json_object_object_add(ret_peers, peername, obj);
		}

		if (json_object_object_length(ret_peers))
			json_object_object_add(ret, "peers", ret_peers);
		else
			json_object_put(ret_peers);
	}

	struct json_object *config_groups;
	if (json_object_object_get_ex(config, "groups", &config_groups)) {
		struct json_object *obj = get_peer_groups(config_groups, peers);
		if (obj)
			json_object_object_add(ret, "groups", obj);
	}


	if (!json_object_object_length(ret)) {
		json_object_put(ret);
		return NULL;
	}

	return ret;
}

static struct json_object * get_peer_groups(struct json_object *groups, struct json_object *peers) {
	if (!json_object_is_type(groups, json_type_object))
		return NULL;

	struct json_object *ret = json_object_new_object();

	json_object_object_foreach(groups, name, group) {
		struct json_object *g = get_peer_group(group, peers);
		if (g)
			json_object_object_add(ret, name, g);
	}

	if (!json_object_object_length(ret)) {
		json_object_put(ret);
		return NULL;
	}

	return ret;
}

static struct json_object * get_mesh_vpn(void) {
	struct json_object *ret = NULL;
	struct json_object *status = NULL;
	struct json_object *site = NULL;

	status = get_status();
	if (!status)
		goto end;

	struct json_object *peers;
	if (!json_object_object_get_ex(status, "peers", &peers))
		goto end;

	site = gluonutil_load_site_config();
	if (!site)
		goto end;

	struct json_object *fastd_mesh_vpn;
	if (!json_object_object_get_ex(site, "fastd_mesh_vpn", &fastd_mesh_vpn))
		goto end;

	ret = get_peer_group(fastd_mesh_vpn, peers);

 end:
	json_object_put(site);
	json_object_put(status);

	return ret;
}

static struct json_object * respondd_provider_statistics(void) {
	struct json_object *ret = json_object_new_object();

	struct json_object *mesh_vpn = get_mesh_vpn();
	if (mesh_vpn)
		json_object_object_add(ret, "mesh_vpn", mesh_vpn);

	return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{"statistics", respondd_provider_statistics},
	{}
};
