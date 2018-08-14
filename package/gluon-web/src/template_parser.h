/*
 * gluon-web Template - Parser header
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

#ifndef _TEMPLATE_PARSER_H_
#define _TEMPLATE_PARSER_H_

#include <lua.h>


struct template_parser;


struct template_parser * template_open(const char *file);
struct template_parser * template_string(const char *str, size_t len);
void template_close(struct template_parser *parser);

const char *template_reader(lua_State *L, void *ud, size_t *sz);
int template_error(lua_State *L, struct template_parser *parser);

#endif
