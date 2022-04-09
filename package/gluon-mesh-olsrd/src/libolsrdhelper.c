/*
  Copyright (c) 2021, Maciej Krüger <maciej@xeredo.it>
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

#include "libolsrdhelper.h"
#include "uclient.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <stdbool.h>
#include <sys/wait.h>

#include <libubox/blobmsg.h>
#include <libubox/uloop.h>

#define USER_AGENT "olsrdhelper (libuclient)"

#define BASE_URL_1 "http://127.0.0.1:9090"
#define BASE_URL_1_LEN sizeof(BASE_URL_1)
#define BASE_URL_2 "http://127.0.0.1:1980/telnet"
#define BASE_URL_2_LEN sizeof(BASE_URL_2)

// 10 mb
#define MAX_RESPONSE (1024 * 1024 * 1024 * 10)
#define PACKET (1024 * 1024)

struct list_obj {
	char* data;
	size_t len;
	struct list_obj *next;
};

struct get_data_ctx {
	struct list_obj *current;
	struct list_obj *start;
	size_t total_length;
	int error;
};

struct recv_json_ctx {
	size_t size;
	int error;
	json_object *parsed;

	struct get_data_ctx *get_data;
};

struct recv_txt_ctx {
	size_t size;
	int error;
	char *data;

	struct get_data_ctx *get_data;
};

/** Recieves all the data */
struct get_data_ctx * get_all_data_init() {
	struct get_data_ctx *ctx = malloc(sizeof(struct get_data_ctx));

	if (!ctx)
		goto fail;

	*ctx = (struct get_data_ctx){
		.total_length = 0,
		.error = 0
	};

	ctx->start = malloc(sizeof(struct list_obj));
	if (!ctx->start)
		goto fail;

	*ctx->start = (struct list_obj){
		.len = 0,
		.next = NULL
	};

	ctx->current = ctx->start;

	return ctx;

fail:
	if (ctx) {
		if (ctx->start)
			free(ctx->start);

		free(ctx);
	}

	return NULL;
}

// returns true when we are not done (if (process) return)
bool get_all_data_process(struct uclient *cl, struct get_data_ctx *ctx) {
	char buf[PACKET];
	size_t len;

	while (true) {
		len = uclient_read_account(cl, buf, sizeof(buf));

		if (len == -1) {
			ctx->error = 1;
			return false;
		}

		if (!len) {
			return false;
		}

		ctx->current->data = malloc(len);
		if (!ctx->current->data) {
			ctx->error = 1;
			return false;
		}
		ctx->current->len = len;

		memcpy(ctx->current->data, buf, len);
		ctx->total_length += len;

		ctx->current->next = malloc(sizeof(struct list_obj));
		*ctx->current->next = (struct list_obj){
			.len = 0,
			.next = NULL
		};
		ctx->current = ctx->current->next;
	}

	return true;
}

int get_all_data_finalize(struct get_data_ctx *ctx, char ** data, size_t * size) {
	if (ctx->error) {
		int error = ctx->error;

		// TODO: free

		return error;
	};

	ctx->total_length++; // trailing null

	*data = malloc(ctx->total_length);
	if (!data)
		return 1;

	size_t offset = 0;

	struct list_obj *prev;

	ctx->current = ctx->start;
	while(ctx->current) {
		if (ctx->current->len) {
			memcpy(*data + offset, ctx->current->data, ctx->current->len);
			offset += ctx->current->len;
			free(ctx->current->data);
		}

		prev = ctx->current;
		ctx->current = ctx->current->next;
		free(prev);
	}

	(*data)[ctx->total_length - 1] = '\0';
	*size = ctx->total_length;

	return 0;
}

/** Receives data from uclient and writes it to memory */
static void recv_json_cb(struct uclient *cl) {
	struct recv_json_ctx *ctx = uclient_get_custom(cl);

	if (get_all_data_process(cl, ctx->get_data)) {
		return;
	}
}

static void recv_json_eof_cb(struct uclient *cl) {
	struct recv_json_ctx *ctx = uclient_get_custom(cl);

	char * data;
	size_t size;

	if (get_all_data_finalize(ctx->get_data, &data, &size)) {
		ctx->error = UCLIENT_ERROR_SIZE_MISMATCH;
		return;
	}

	if (data[0] != "{"[0]) {
		ctx->error = UCLIENT_ERROR_NOT_JSON;
		return;
	}

	// TODO: handle parser error, add error code for malformed json
	ctx->parsed = json_tokener_parse(data);
}

/** Receives data from uclient and writes it to memory */
static void recv_txt_cb(struct uclient *cl) {
	struct recv_txt_ctx *ctx = uclient_get_custom(cl);

	if (get_all_data_process(cl, ctx->get_data)) {
		return;
	}
}

static void recv_txt_eof_cb(struct uclient *cl) {
	struct recv_txt_ctx *ctx = uclient_get_custom(cl);

	if (get_all_data_finalize(ctx->get_data, &ctx->data, &ctx->size)) {
		ctx->error = UCLIENT_ERROR_SIZE_MISMATCH;
		return;
	}
}

bool success_exit(char *cmd, ...) {
	pid_t pid = fork();

	if (pid == 0) {
		va_list val;
    char **args = NULL;
    int argc;

    // Determine number of variadic arguments
    va_start(val, cmd);
    argc = 2; // leading command + trailing NULL
    while (va_arg(val, char *) != NULL)
      argc++;
    va_end(val);

    // Allocate args, put references to command / variadic arguments + NULL in args
    args = (char **) malloc(argc * sizeof(char*));
    args[0] = cmd;
    va_start(val, cmd);
    int i = 0;
    do {
      i++;
      args[i] = va_arg(val, char *);
			// since this triggers AFTERWARDS, the trailing null still gets pushed
    } while (args[i] != NULL);
    va_end(val);

		execv(cmd, args);
		exit(1);
		return false;
	}

	int status;

	if (waitpid(pid, &status, 0) == -1) {
		return false;
	}

	if (WIFEXITED(status)) {
		return WEXITSTATUS(status) == 0;
	}

	return false;
}

// get enabled from site.conf mesh.olsrX.enabled, get running from service X status
int oi(struct olsr_info **out) {
	int ex = 0;

	json_object *site = gluonutil_load_site_config();
	if (!site)
		goto fail;

	json_object *mesh = json_object_object_get(site, "mesh");
	if (!mesh)
		goto fail;

	json_object *olsrd = json_object_object_get(mesh, "olsrd");
	if (!olsrd)
		goto fail;

	json_object *v1 = json_object_object_get(olsrd, "v1_4");
	json_object *v2 = json_object_object_get(olsrd, "v2");

	struct olsr_info *info = (struct olsr_info *) malloc(sizeof(struct olsr_info));

	*info = (struct olsr_info){
		.olsr1 = {
			.enabled = false,
			.running = false,
		},
		.olsr2 = {
			.enabled = false,
			.running = false,
		}
	};

	if (v1 && json_object_get_boolean(json_object_object_get(v1, "enable"))) {
		info->olsr1.enabled = true;

		if (success_exit("/etc/init.d/olsrd", "running", NULL)) {
			info->olsr1.running = true;
		}
	}

	if (v2 && json_object_get_boolean(json_object_object_get(v2, "enable"))) {
		info->olsr2.enabled = true;

		// FIXME: we SHOULD use running but IT DOESN'T FUCKING EXIST
		// use either /tmp/run/olsrd2.pid or something else...
		if (success_exit("/etc/init.d/olsrd2", "running", NULL)) {
			info->olsr2.running = true;
		}

		/*
		this should be added to /etc/init.d/olsrd2 to fix it

running() {
  test -e "/tmp/run/olsrd2.pid" && test -e "/proc/$(cat "/tmp/run/olsrd2.pid")" && return 0
  return 1
}

extra_command "running" "Check if service is running"

		*/
	}

	*out = info;

end:
	return ex;

fail:
	ex = 1;
	goto end;
}

int olsr1_get_nodeinfo(const char *path, json_object **out) {
  char url[BASE_URL_1_LEN + strlen(path) + 2];
	sprintf(url, "%s/%s", BASE_URL_1, path);

	uloop_init();
  struct recv_json_ctx json_ctx = { };
	json_ctx.get_data = get_all_data_init();
	if (!json_ctx.get_data)
		return 1;

	int err_code = get_url(url, &recv_json_cb, &recv_json_eof_cb, &json_ctx, -1);
	uloop_done();

  if (err_code) {
    return err_code;
  }

	if (json_ctx.error) {
		return json_ctx.error;
	}

	*out = json_ctx.parsed;

  return 0;
}

int olsr2_get_nodeinfo(const char *cmd, json_object **out) {
	char url[BASE_URL_2_LEN + strlen(cmd) + 2];
	sprintf(url, "%s/%s", BASE_URL_2, cmd);

	uloop_init();
  struct recv_json_ctx json_ctx = { };
	json_ctx.get_data = get_all_data_init();
	if (!json_ctx.get_data)
		return 1;
	int err_code = get_url(url, &recv_json_cb, &recv_json_eof_cb, &json_ctx, -1);
	uloop_done();

  if (err_code) {
    return err_code;
  }

	if (json_ctx.error) {
		return json_ctx.error;
	}

	*out = json_ctx.parsed;

  return 0;
}

int olsr2_get_nodeinfo_raw(const char *cmd, char **out) {
	char url[BASE_URL_2_LEN + strlen(cmd) + 2];
	sprintf(url, "%s/%s", BASE_URL_2, cmd);

	uloop_init();
  struct recv_txt_ctx txt_ctx = { };
	txt_ctx.get_data = get_all_data_init();
	if (!txt_ctx.get_data)
		return 1;
	int err_code = get_url(url, &recv_txt_cb, &recv_txt_eof_cb, &txt_ctx, -1);
	uloop_done();

  if (err_code) {
    return err_code;
  }

	if (txt_ctx.error) {
		return txt_ctx.error;
	}

	*out = txt_ctx.data;

  return 0;
}
