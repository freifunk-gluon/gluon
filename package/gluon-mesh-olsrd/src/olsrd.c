/*

Copyright 2022 Maciej Krüger <maciej@xeredo.it>

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

#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <lua-jsonc.h>

#include <libolsrdhelper.h>

#define OLSRD "gluon.olsrd"

static int find_module_version (lua_State *L) {
  const char *mod = luaL_checkstring(L, 1);

  DIR *d = opendir("/usr/lib");

  if (d == NULL)
    return luaL_error(L, "cannot open /usr/lib: %s", strerror(errno));

  struct dirent *entry;
  while ((entry = readdir(d)) != NULL) {
    if (entry->d_type == DT_REG && !strncmp(mod, entry->d_name, strlen(mod))) {
      lua_pushstring(L, entry->d_name);
      closedir(d);
      return 1;
    }
  }

  closedir(d);
  return luaL_error(L, "mod %s not found", mod);
}

static int lua_olsr1_get_nodeinfo (lua_State *L) {
  const char *query = luaL_checkstring(L, 1);

  json_object *resp;

  if (olsr1_get_nodeinfo(query, &resp))
    return luaL_error(L, "olsr1_get_nodeinfo(%s) failed", query);

  lua_jsonc_push_json(L, resp);

  return 1;
}

static int lua_olsr2_get_nodeinfo (lua_State *L) {
  const char *query = luaL_checkstring(L, 1);

  json_object *resp;

  if (olsr2_get_nodeinfo(query, &resp))
    return luaL_error(L, "olsr2_get_nodeinfo(%s) failed", query);

  lua_jsonc_push_json(L, resp);

  return 1;
}

static int lua_olsr2_get_nodeinfo_raw (lua_State *L) {
  const char *query = luaL_checkstring(L, 1);

  char *resp;

  if (olsr2_get_nodeinfo_raw(query, &resp))
    return luaL_error(L, "olsr2_get_nodeinfo_raw(%s) failed", query);

  lua_pushstring(L, resp);

  return 1;
}

static int lua_olsr1_get_neigh (lua_State *L) {
  json_object *resp = olsr1_get_neigh();

  if (!resp)
    return luaL_error(L, "olsr2_get_neigh() failed");

  lua_jsonc_push_json(L, resp);

  return 1;
}

static int lua_olsr2_get_neigh (lua_State *L) {
  json_object *resp = olsr2_get_neigh();

  if (!resp)
    return luaL_error(L, "olsr2_get_neigh() failed");

  lua_jsonc_push_json(L, resp);

  return 1;
}

static int lua_oi (lua_State *L) {
  struct olsr_info *info;

  if (oi(&info))
    return luaL_error(L, "olsr_info() call failed");

  lua_newtable(L);


  lua_newtable(L); // olsr1

  lua_pushboolean(L, info->olsr1.enabled);
  lua_setfield(L, -2, "enabled");

  lua_pushboolean(L, info->olsr1.running);
  lua_setfield(L, -2, "running");

  lua_setfield(L, -2, "olsr1");


  lua_newtable(L); // olsr2

  lua_pushboolean(L, info->olsr2.enabled);
  lua_setfield(L, -2, "enabled");

  lua_pushboolean(L, info->olsr2.running);
  lua_setfield(L, -2, "running");

  lua_setfield(L, -2, "olsr2");

  return 1;
}

static const luaL_reg olsrd_methods[] = {
  { "find_module_version", find_module_version },

  { "oi", lua_oi },

  { "olsr1_get_nodeinfo", lua_olsr1_get_nodeinfo },

  { "olsr2_get_nodeinfo", lua_olsr2_get_nodeinfo },
  { "olsr2_get_nodeinfo_raw", lua_olsr2_get_nodeinfo_raw },

  { "olsr1_get_neigh", lua_olsr1_get_neigh },
  { "olsr2_get_neigh", lua_olsr2_get_neigh },
	{ }
};

int luaopen_gluon_olsrd(lua_State *L)
{
	luaL_register(L, OLSRD, olsrd_methods);

	return 1;
}
