/*
 * gluon-web Template - Utility header
 *
 *   Copyright (C) 2010-2012 Jo-Philipp Wich <jow@openwrt.org>
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

#ifndef _TEMPLATE_UTILS_H_
#define _TEMPLATE_UTILS_H_

#include <stdbool.h>
#include <stddef.h>


/* buffer object */
struct template_buffer {
	char *data;
	char *dptr;
	size_t size;
};

struct template_buffer * buf_init(size_t size);
bool buf_putchar(struct template_buffer *buf, char c);
bool buf_append(struct template_buffer *buf, const char *s, size_t len);
char * buf_destroy(struct template_buffer *buf);

/* read buffer length */
static inline size_t buf_length(const struct template_buffer *buf)
{
	return buf->dptr - buf->data;
}

bool pcdata(const char *s, size_t l, char **out, size_t *outl);

#endif
