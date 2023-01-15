#include "libgluonutil.h"
#include "lua-jsonc.h"

#include <limits.h>
#include <lualib.h>
#include <lauxlib.h>


#define UDATA "gluon.site"


static struct json_object * gluon_site_udata(lua_State *L, int narg) {
	return *(struct json_object **)luaL_checkudata(L, narg, UDATA);
}

static void gluon_site_push_none(lua_State *L) {
	lua_pushlightuserdata(L, gluon_site_push_none);
	lua_rawget(L, LUA_REGISTRYINDEX);
}

static void gluon_site_do_wrap(lua_State *L, struct json_object *obj) {
	struct json_object **objp = lua_newuserdata(L, sizeof(struct json_object *));
	*objp = json_object_get(obj);
	luaL_getmetatable(L, UDATA);
	lua_setmetatable(L, -2);
}

static void gluon_site_wrap(lua_State *L, struct json_object *obj) {
	if (obj)
		gluon_site_do_wrap(L, obj);
	else
		gluon_site_push_none(L);
}


static int gluon_site_index(lua_State *L) {
	struct json_object *obj = gluon_site_udata(L, 1);
	const char *key;
	lua_Number lua_index;
	size_t index;
	struct json_object *v = NULL;

	switch (json_object_get_type(obj)) {
	case json_type_object:
		key = lua_tostring(L, 2);
		if (key)
			json_object_object_get_ex(obj, key, &v);
		break;

	case json_type_array:
		index = lua_index = lua_tonumber(L, 2);
		if (lua_index == (lua_Number)index && index >= 1)
			v = json_object_array_get_idx(obj, index-1);
		break;

	case json_type_string:
	case json_type_null:
		break;

	case json_type_boolean:
	case json_type_int:
	case json_type_double:
		luaL_error(L, "attempt to index a number or boolean value");
		__builtin_unreachable();
	}

	gluon_site_wrap(L, v);
	return 1;
}

static int gluon_site_call(lua_State *L) {
	struct json_object *obj = gluon_site_udata(L, 1);

	if (obj) {
		lua_jsonc_push_json(L, obj);
	} else {
		if (lua_isnone(L, 2))
			lua_pushnil(L);
		else
			lua_pushvalue(L, 2);
	}

	return 1;
}

static int gluon_site_gc(lua_State *L) {
	json_object_put(gluon_site_udata(L, 1));
	return 0;
}

static const luaL_reg R[] = {
	{ "__index", gluon_site_index },
	{ "__call", gluon_site_call },
	{ "__gc", gluon_site_gc },
	{}
};

int luaopen_gluon_site(lua_State *L) {
	luaL_newmetatable(L, UDATA);
	luaL_register(L, NULL, R);
	lua_pop(L, 1);

	/* Create "none" object */
	lua_pushlightuserdata(L, gluon_site_push_none);
	gluon_site_do_wrap(L, NULL);
	lua_rawset(L, LUA_REGISTRYINDEX);

	struct json_object *site = gluonutil_load_site_config();
	gluon_site_wrap(L, site);
	json_object_put(site);

	return 1;
}
