/*
 * lmo - Lua Machine Objects - General header
 *
 *   Copyright (C) 2009-2012 Jo-Philipp Wich <jow@openwrt.org>
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

#ifndef _TEMPLATE_LMO_H_
#define _TEMPLATE_LMO_H_

#include <stddef.h>


int lmo_load_catalog(const char *lang, const char *dir);
int lmo_change_catalog(const char *lang);
int lmo_translate(const char *key, size_t keylen, char **out, size_t *outlen);

#endif
