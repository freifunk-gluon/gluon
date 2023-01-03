/*
 * gluon-web Template - Utility functions
 *
 *   Copyright (C) 2010 Jo-Philipp Wich <jow@openwrt.org>
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

#include "template_utils.h"
#include "template_lmo.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* initialize a buffer object */
struct template_buffer * buf_init(size_t size)
{
	struct template_buffer *buf = malloc(sizeof(*buf));

	if (buf != NULL) {
		buf->size = size;
		buf->data = malloc(buf->size);
		buf->dptr = buf->data;

		if (buf->data != NULL || size == 0)
			return buf;

		free(buf);
	}

	return NULL;
}

/* grow buffer */
static bool buf_grow(struct template_buffer *buf, size_t len)
{
	size_t off = buf->dptr - buf->data, left = buf->size - off;
	if (len <= left)
		return true;

	size_t diff = len - left;
	if (diff < 1024)
		diff = 1024;

	char *data = realloc(buf->data, buf->size + diff);
	if (data == NULL)
		return false;

	buf->data  = data;
	buf->dptr  = data + off;
	buf->size += diff;

	return true;
}

/* put one char into buffer object */
bool buf_putchar(struct template_buffer *buf, char c)
{
	if (!buf_grow(buf, 1))
		return false;

	*(buf->dptr++) = c;

	return true;
}

/* append data to buffer */
bool buf_append(struct template_buffer *buf, const char *s, size_t len)
{
	if (!buf_grow(buf, len))
		return false;

	memcpy(buf->dptr, s, len);
	buf->dptr += len;

	return true;
}

/* destroy buffer object and return pointer to data */
char * buf_destroy(struct template_buffer *buf)
{
	char *data = buf->data;

	free(buf);
	return data;
}


/* calculate the number of expected continuation chars */
static inline size_t mb_num_chars(unsigned char c)
{
	if ((c & 0xE0) == 0xC0)
		return 2;
	else if ((c & 0xF0) == 0xE0)
		return 3;
	else if ((c & 0xF8) == 0xF0)
		return 4;
	else if ((c & 0xFC) == 0xF8)
		return 5;
	else if ((c & 0xFE) == 0xFC)
		return 6;

	return 1;
}

/* test whether the given byte is a valid continuation char */
static inline bool mb_is_cont(unsigned char c)
{
	return ((c >= 0x80) && (c <= 0xBF));
}

/* test whether the byte sequence at the given pointer with the given
 * length is the shortest possible representation of the code point */
static inline bool mb_is_shortest(const unsigned char *s, size_t n)
{
	switch (n)
	{
		case 2:
			/* 1100000x (10xxxxxx) */
			return !(((*s >> 1) == 0x60) &&
				((*(s+1) >> 6) == 0x02));

		case 3:
			/* 11100000 100xxxxx (10xxxxxx) */
			return !((*s == 0xE0) &&
				((*(s+1) >> 5) == 0x04) &&
				((*(s+2) >> 6) == 0x02));

		case 4:
			/* 11110000 1000xxxx (10xxxxxx 10xxxxxx) */
			return !((*s == 0xF0) &&
				((*(s+1) >> 4) == 0x08) &&
				((*(s+2) >> 6) == 0x02) &&
				((*(s+3) >> 6) == 0x02));

		case 5:
			/* 11111000 10000xxx (10xxxxxx 10xxxxxx 10xxxxxx) */
			return !((*s == 0xF8) &&
				((*(s+1) >> 3) == 0x10) &&
				((*(s+2) >> 6) == 0x02) &&
				((*(s+3) >> 6) == 0x02) &&
				((*(s+4) >> 6) == 0x02));

		case 6:
			/* 11111100 100000xx (10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx) */
			return !((*s == 0xF8) &&
				((*(s+1) >> 2) == 0x20) &&
				((*(s+2) >> 6) == 0x02) &&
				((*(s+3) >> 6) == 0x02) &&
				((*(s+4) >> 6) == 0x02) &&
				((*(s+5) >> 6) == 0x02));
	}

	return true;
}

/* test whether the byte sequence at the given pointer with the given
 * length is an UTF-16 surrogate */
static inline bool mb_is_surrogate(const unsigned char *s, size_t n)
{
	return ((n == 3) && (*s == 0xED) && (*(s+1) >= 0xA0) && (*(s+1) <= 0xBF));
}

/* test whether the byte sequence at the given pointer with the given
 * length is an illegal UTF-8 code point */
static inline bool mb_is_illegal(const unsigned char *s, size_t n)
{
	return ((n == 3) && (*s == 0xEF) && (*(s+1) == 0xBF) &&
			(*(s+2) >= 0xBE) && (*(s+2) <= 0xBF));
}


/* scan given source string, validate UTF-8 sequence and store result
 * in given buffer object */
static size_t validate_utf8(const unsigned char **s, size_t l, struct template_buffer *buf)
{
	const unsigned char *ptr = *s;
	size_t o = 0, v, n;

	/* ascii byte without null */
	if ((*(ptr+0) >= 0x01) && (*(ptr+0) <= 0x7F)) {
		if (!buf_putchar(buf, *ptr++))
			return 0;

		o = 1;
	}

	/* multi byte sequence */
	else if ((n = mb_num_chars(*ptr)) > 1) {
		/* count valid chars */
		for (v = 1; (v <= n) && ((o+v) < l) && mb_is_cont(*(ptr+v)); v++);

		switch (n)
		{
			case 6:
			case 5:
				/* five and six byte sequences are always invalid */
				if (!buf_putchar(buf, '?'))
					return 0;

				break;

			default:
				/* if the number of valid continuation bytes matches the
				 * expected number and if the sequence is legal, copy
				 * the bytes to the destination buffer */
				if ((v == n) && mb_is_shortest(ptr, n) &&
					!mb_is_surrogate(ptr, n) && !mb_is_illegal(ptr, n))
				{
					/* copy sequence */
					if (!buf_append(buf, (const char *)ptr, n))
						return 0;
				}

				/* the found sequence is illegal, skip it */
				else
				{
					/* invalid sequence */
					if (!buf_putchar(buf, '?'))
						return 0;
				}

				break;
		}

		/* advance beyond the last found valid continuation char */
		o = v;
		ptr += v;
	}

	/* invalid byte (0x00) */
	else {
		if (!buf_putchar(buf, '?')) /* or 0xEF, 0xBF, 0xBD */
			return 0;

		o = 1;
		ptr++;
	}

	*s = ptr;
	return o;
}

/* Sanitize given string and strip all invalid XML bytes
 * Validate UTF-8 sequences
 * Escape XML control chars */
bool pcdata(const char *s, size_t l, char **out, size_t *outl)
{
	struct template_buffer *buf = buf_init(l);
	const unsigned char *ptr = (const unsigned char *)s;
	size_t o, v;
	char esq[8];
	int esl;

	if (!buf)
		return false;

	for (o = 0; o < l; o++)	{
		/* Invalid XML bytes */
		if ((*ptr <= 0x08) ||
		((*ptr >= 0x0B) && (*ptr <= 0x0C)) ||
		((*ptr >= 0x0E) && (*ptr <= 0x1F)) ||
		(*ptr == 0x7F)) {
			ptr++;
		}

		/* Escapes */
		else if ((*ptr == '\'') ||
		(*ptr == '"') ||
		(*ptr == '&') ||
		(*ptr == '<') ||
		(*ptr == '>')) {
			esl = snprintf(esq, sizeof(esq), "&#%i;", *ptr);

			if (!buf_append(buf, esq, esl))
				break;

			ptr++;
		}

		/* ascii char */
		else if (*ptr <= 0x7F) {
			buf_putchar(buf, (char)*ptr++);
		}

		/* multi byte sequence */
		else {
			if (!(v = validate_utf8(&ptr, l - o, buf)))
				break;

			o += (v - 1);
		}
	}

	*outl = buf_length(buf);
	*out = buf_destroy(buf);
	return true;
}
