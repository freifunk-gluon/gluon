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

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>


struct lmo_entry {
	uint32_t key_id;
	uint32_t val_id;
	uint32_t offset;
	uint32_t length;
} __attribute__((packed));
typedef struct lmo_entry lmo_entry_t;


struct lmo_catalog {
	size_t length;
	const lmo_entry_t *index;
	char *data;
	const char *end;
};

typedef struct lmo_catalog lmo_catalog_t;


uint32_t sfh_hash(const void *input, size_t len);

bool lmo_load(lmo_catalog_t *cat, const char *file);
void lmo_unload(lmo_catalog_t *cat);
bool lmo_translate(const lmo_catalog_t *cat, const char *key, size_t keylen, const char **out, size_t *outlen);

#endif
