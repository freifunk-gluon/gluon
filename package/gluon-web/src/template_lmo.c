/*
 * lmo - Lua Machine Objects - Base functions
 *
 *   Copyright (C) 2009-2010 Jo-Philipp Wich <jow@openwrt.org>
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

#include "template_lmo.h"

#include <sys/stat.h>
#include <sys/mman.h>

#include <arpa/inet.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


static inline uint16_t get_le16(const void *data) {
	const uint8_t *d = data;
	return (((uint16_t)d[1]) << 8) | d[0];
}

static inline uint32_t get_be32(const void *data) {
	const uint8_t *d = data;
	return (((uint32_t)d[0]) << 24)
		| (((uint32_t)d[1]) << 16)
		| (((uint32_t)d[2]) << 8)
		| d[3];
}

/*
 * Hash function from http://www.azillionmonkeys.com/qed/hash.html
 * Copyright (C) 2004-2008 by Paul Hsieh
 */
uint32_t sfh_hash(const void *input, size_t len)
{
	const uint8_t *data = input;
	uint32_t hash = len, tmp;

	/* Main loop */
	for (; len > 3; len -= 4) {
		hash  += get_le16(data);
		tmp    = (get_le16(data+2) << 11) ^ hash;
		hash   = (hash << 16) ^ tmp;
		data  += 4;
		hash  += hash >> 11;
	}

	/* Handle end cases */
	switch (len) {
	case 3: hash += get_le16(data);
		hash ^= hash << 16;
		hash ^= data[2] << 18;
		hash += hash >> 11;
		break;
	case 2: hash += get_le16(data);
		hash ^= hash << 11;
		hash += hash >> 17;
		break;
	case 1: hash += *data;
		hash ^= hash << 10;
		hash += hash >> 1;
	}

	/* Force "avalanching" of final 127 bits */
	hash ^= hash << 3;
	hash += hash >> 5;
	hash ^= hash << 4;
	hash += hash >> 17;
	hash ^= hash << 25;
	hash += hash >> 6;

	return hash;
}

bool lmo_load(lmo_catalog_t *cat, const char *file)
{
	int fd = -1;
	struct stat s;

	cat->data = MAP_FAILED;

	fd = open(file, O_RDONLY|O_CLOEXEC);
	if (fd < 0)
		goto err;

	if (fstat(fd, &s))
		goto err;

	cat->data = mmap(NULL, s.st_size, PROT_READ, MAP_SHARED, fd, 0);

	close(fd);
	fd = -1;

	if (cat->data == MAP_FAILED)
		goto err;

	cat->end = cat->data + s.st_size;

	uint32_t idx_offset = get_be32(cat->end - sizeof(uint32_t));
	cat->index = (const lmo_entry_t *)(cat->data + idx_offset);

	if ((const char *)cat->index > (cat->end - sizeof(uint32_t)))
		goto err;

	cat->length = (cat->end - sizeof(uint32_t) - (const char *)cat->index) / sizeof(lmo_entry_t);

	return true;

err:
	if (fd >= 0)
		close(fd);

	if (cat->data != MAP_FAILED)
		munmap(cat->data, cat->end - cat->data);

	return false;
}

void lmo_unload(lmo_catalog_t *cat)
{
	if (cat->data != MAP_FAILED)
		munmap(cat->data, cat->end - cat->data);
}


static int lmo_compare_entry(const void *a, const void *b)
{
	const lmo_entry_t *ea = a, *eb = b;
	uint32_t ka = ntohl(ea->key_id), kb = ntohl(eb->key_id);

	if (ka < kb)
		return -1;
	else if (ka > kb)
		return 1;
	else
		return 0;
}

static const lmo_entry_t * lmo_find_entry(const lmo_catalog_t *cat, uint32_t hash)
{
	lmo_entry_t key;
	key.key_id = htonl(hash);

	return bsearch(&key, cat->index, cat->length, sizeof(lmo_entry_t), lmo_compare_entry);
}

bool lmo_translate(const lmo_catalog_t *cat, const char *key, size_t keylen, const char **out, size_t *outlen)
{
	uint32_t hash = sfh_hash(key, keylen);
	const lmo_entry_t *e = lmo_find_entry(cat, hash);
	if (!e)
		return false;

	*out = cat->data + ntohl(e->offset);
	*outlen = ntohl(e->length);

	if (*out + *outlen > cat->end)
		return false;

	return true;
}
