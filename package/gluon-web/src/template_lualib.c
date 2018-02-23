/*
 * gluon-web Template - Lua binding
 *
 *   Copyright (C) 2009 Jo-Philipp Wich <jow@openwrt.org>
 *   Copyright (C) 2018 Matthias Schiffer <mschiffer@universe-factory.net>
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#include "template_parser.h"
#include "template_utils.h"
#include "template_lmo.h"

#include <lualib.h>
#include <lauxlib.h>

#include <errno.h>
#include <stdlib.h>
#include <string.h>


#define TEMPLATE_LUALIB_META  "gluon.web.template.parser"


static int template_L_do_parse(lua_State *L, struct template_parser *parser, const char *chunkname)
{
	int lua_status, rv;

	if (!parser)
	{
		lua_pushnil(L);
		lua_pushinteger(L, errno);
		lua_pushstring(L, strerror(errno));
		return 3;
	}

	lua_status = lua_load(L, template_reader, parser, chunkname);

	if (lua_status == 0)
		rv = 1;
	else
		rv = template_error(L, parser);

	template_close(parser);

	return rv;
}

static int template_L_parse(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);
	struct template_parser *parser = template_open(file);

	return template_L_do_parse(L, parser, file);
}

static int template_L_parse_string(lua_State *L)
{
	size_t len;
	const char *str = luaL_checklstring(L, 1, &len);
	struct template_parser *parser = template_string(str, len);

	return template_L_do_parse(L, parser, "[string]");
}

static int template_L_pcdata(lua_State *L)
{
	size_t inlen, outlen;
	char *out;
	const char *in = luaL_checklstring(L, 1, &inlen);
	if (!pcdata(in, inlen, &out, &outlen))
		return 0;

	lua_pushlstring(L, out, outlen);
	free(out);

	return 1;
}

static int template_L_load_catalog(lua_State *L) {
	const char *lang = luaL_optstring(L, 1, "en");
	const char *dir  = luaL_checkstring(L, 2);
	lua_pushboolean(L, lmo_load_catalog(lang, dir));
	return 1;
}

static int template_L_translate(lua_State *L) {
	size_t len;
	char *tr;
	size_t trlen;
	const char *key = luaL_checklstring(L, 1, &len);

	if (lmo_translate(key, len, &tr, &trlen))
		lua_pushlstring(L, tr, trlen);
	else
		lua_pushnil(L);

	return 1;
}


/* module table */
static const luaL_reg R[] = {
	{ "parse",          template_L_parse },
	{ "parse_string",   template_L_parse_string },
	{ "pcdata",         template_L_pcdata },
	{ "load_catalog",   template_L_load_catalog },
	{ "translate",      template_L_translate },
	{}
};

__attribute__ ((visibility("default")))
LUALIB_API int luaopen_gluon_web_template_parser(lua_State *L) {
	luaL_register(L, TEMPLATE_LUALIB_META, R);
	return 1;
}
