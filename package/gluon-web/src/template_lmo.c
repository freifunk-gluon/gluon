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
#include <dirent.h>
#include <fcntl.h>
#include <fnmatch.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>


struct lmo_entry {
	uint32_t key_id;
	uint32_t val_id;
	uint32_t offset;
	uint32_t length;
} __attribute__((packed));

typedef struct lmo_entry lmo_entry_t;


struct lmo_archive {
	size_t length;
	const lmo_entry_t *index;
	char *data;
	const char *end;
	struct lmo_archive *next;
};

typedef struct lmo_archive lmo_archive_t;


struct lmo_catalog {
	char lang[6];
	struct lmo_archive *archives;
	struct lmo_catalog *next;
};

typedef struct lmo_catalog lmo_catalog_t;


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
static uint32_t sfh_hash(const void *input, size_t len)
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

static lmo_archive_t * lmo_open(const char *file)
{
	int fd = -1;
	lmo_archive_t *ar = NULL;
	struct stat s;

	if ((fd = open(file, O_RDONLY|O_CLOEXEC)) == -1)
		goto err;

	if (fstat(fd, &s) == -1)
		goto err;

	if ((ar = calloc(1, sizeof(*ar))) != NULL) {
		if ((ar->data = mmap(NULL, s.st_size, PROT_READ, MAP_SHARED, fd, 0)) == MAP_FAILED)
			goto err;

		ar->end = ar->data + s.st_size;

		uint32_t idx_offset = get_be32(ar->end - sizeof(uint32_t));
		ar->index  = (const lmo_entry_t *)(ar->data + idx_offset);

		if ((const char *)ar->index > (ar->end - sizeof(uint32_t)))
			goto err;

		ar->length = (ar->end - sizeof(uint32_t) - (const char *)ar->index) / sizeof(lmo_entry_t);

		return ar;
	}

err:
	if (fd >= 0)
		close(fd);

	if (ar != NULL) {
		if ((ar->data != NULL) && (ar->data != MAP_FAILED))
			munmap(ar->data, ar->end - ar->data);

		free(ar);
	}

	return NULL;
}


static lmo_catalog_t *lmo_catalogs;
static lmo_catalog_t *lmo_active_catalog;

bool lmo_change_catalog(const char *lang)
{
	lmo_catalog_t *cat;

	for (cat = lmo_catalogs; cat; cat = cat->next) {
		if (!strncmp(cat->lang, lang, sizeof(cat->lang))) {
			lmo_active_catalog = cat;
			return true;
		}
	}

	return false;
}

bool lmo_load_catalog(const char *lang, const char *dir)
{
	DIR *dh = NULL;
	char pattern[16];
	char path[PATH_MAX];
	struct dirent *de = NULL;

	lmo_archive_t *ar = NULL;
	lmo_catalog_t *cat = NULL;

	if (lmo_change_catalog(lang))
		return true;

	if (!(dh = opendir(dir)))
		goto err;

	if (!(cat = calloc(1, sizeof(*cat))))
		goto err;

	snprintf(cat->lang, sizeof(cat->lang), "%s", lang);
	snprintf(pattern, sizeof(pattern), "*.%s.lmo", lang);

	while ((de = readdir(dh)) != NULL) {
		if (!fnmatch(pattern, de->d_name, 0)) {
			snprintf(path, sizeof(path), "%s/%s", dir, de->d_name);
			ar = lmo_open(path);

			if (ar) {
				ar->next = cat->archives;
				cat->archives = ar;
			}
		}
	}

	closedir(dh);

	cat->next = lmo_catalogs;
	lmo_catalogs = cat;

	lmo_active_catalog = cat;

	return true;

err:
	if (dh)
		closedir(dh);
	free(cat);

	return false;
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

static const lmo_entry_t * lmo_find_entry(const lmo_archive_t *ar, uint32_t hash)
{
	lmo_entry_t key;
	key.key_id = htonl(hash);

	return bsearch(&key, ar->index, ar->length, sizeof(lmo_entry_t), lmo_compare_entry);
}

bool lmo_translate(const char *key, size_t keylen, char **out, size_t *outlen)
{
	if (!lmo_active_catalog)
		return false;

	uint32_t hash = sfh_hash(key, keylen);

	for (const lmo_archive_t *ar = lmo_active_catalog->archives; ar; ar = ar->next) {
		const lmo_entry_t *e = lmo_find_entry(ar, hash);
		if (!e)
			continue;

		*out = ar->data + ntohl(e->offset);
		*outlen = ntohl(e->length);

		if (*out + *outlen > ar->end)
			continue;

		return true;
	}

	return false;
}
