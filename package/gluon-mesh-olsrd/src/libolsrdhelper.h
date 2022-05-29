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

#pragma once

#include <json-c/json.h>
#include <libubox/uclient.h>
#include <libgluonutil.h>
#include <uci.h>

struct olsr1_info {
  bool enabled;
  bool running;
};

struct olsr2_info {
  bool enabled;
  bool running;
};

struct olsr_info {
	struct olsr1_info olsr1;
	struct olsr2_info olsr2;
};

int oi(struct olsr_info **out);

int olsr1_get_nodeinfo(const char *path, json_object **out);

int olsr2_get_nodeinfo(const char *cmd, json_object **out);
int olsr2_get_nodeinfo_raw(const char *cmd, char **out);

struct json_object * olsr1_get_neigh(void);
struct json_object * olsr2_get_neigh(void);
