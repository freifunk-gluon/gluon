/*
Copyright 2021 Maciej Krüger <maciej@xeredo.it>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <limits.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "ecdsa_util.h"

#define ECDSA "gluon.ecdsa"

// TODO: fix all the memory leaks

static bool verify(lua_State *L, const char *data, const char *sig, const char *key) {
	struct verify_params params = {
		.good_signatures = 1
	};

	if (!hash_data(&params, data)) {
		return luaL_error(L, "failed hashing data");
	}

	if (!load_signatures(&params, 1, &sig, false)) {
		return luaL_error(L, "failed loading signature");
	}

	if (!load_pubkeys(&params, 1, &key, false)) {
		return luaL_error(L, "failed loading keys");
	}

	return do_verify(&params);
}

static int lua_verify(lua_State *L) {
	lua_pushboolean(L, verify(L, luaL_checkstring(L, 1), luaL_checkstring(L, 2), luaL_checkstring(L, 3)));
	return 1;
}

static const luaL_reg ecdsa_methods[] = {
	{ "verify",			lua_verify          },

	{ }
};

int luaopen_gluon_ecdsa(lua_State *L)
{
	luaL_register(L, ECDSA, ecdsa_methods);

	return 1;
}
