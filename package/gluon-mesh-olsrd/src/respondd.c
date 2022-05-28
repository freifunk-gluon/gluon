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

#include "respondd-common.h"

#include <respondd.h>

#include <json-c/json.h>

#define RESP_SIZE 1024 * 1024 * 1024

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

struct json_object * make_safe(struct json_object * (*fnc)(void)) {
	char * shared = mmap(NULL, RESP_SIZE, PROT_READ | PROT_WRITE,
  	MAP_SHARED | MAP_ANONYMOUS, -1, 0);

	pid_t pid = fork();

	struct json_object *r = NULL;

	if (pid == 0) {
		struct json_object *resp = fnc();
		if (!resp) {
			_exit(EXIT_FAILURE);
		}

		const char *resp_str = json_object_to_json_string(resp);
		size_t len = strlen(resp_str);
		if (len > RESP_SIZE) {
			_exit(EXIT_FAILURE);
		}

		memcpy(shared, resp_str, len);
		_exit(EXIT_SUCCESS);
	} else {
		int status;

		if (waitpid(pid, &status, 0) == -1) {
			goto ret;
		}

		if (WIFEXITED(status)) {
			if (WEXITSTATUS(status) == 0) {
				r = json_tokener_parse(shared);
			}
		}
	}

ret:
	munmap(shared, RESP_SIZE);

	return r;
}

__attribute__ ((visibility ("default")))
const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{"neighbours", respondd_provider_neighbours},
	{}
};
