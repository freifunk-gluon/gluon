/*
 * gluon-web Template - Parser implementation
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

#include "template_parser.h"
#include "template_utils.h"
#include "template_lmo.h"

#include <lualib.h>
#include <lauxlib.h>

#include <sys/stat.h>
#include <sys/mman.h>

#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


typedef enum {
	T_TYPE_INIT,
	T_TYPE_TEXT,
	T_TYPE_COMMENT,
	T_TYPE_EXPR,
	T_TYPE_EXPR_RAW,
	T_TYPE_INCLUDE,
	T_TYPE_I18N,
	T_TYPE_I18N_RAW,
	T_TYPE_CODE,
	T_TYPE_EOF,
} t_type_t;


struct template_chunk {
	const char *s;
	const char *e;
	t_type_t type;
	int line;
};

/* parser state */
struct template_parser {
	size_t size;
	char *data;
	char *off;
	char *lua_chunk;
	int line;
	int in_expr;
	bool strip_before;
	bool strip_after;
	struct template_chunk prv_chunk;
	struct template_chunk cur_chunk;
	const char *file;
};


/* leading and trailing code for different types */
static const char *const gen_code[][2] = {
	[T_TYPE_INIT]     = {NULL,                        NULL},
	[T_TYPE_TEXT]     = {"write('",                   "')"},
	[T_TYPE_COMMENT]  = {NULL,                        NULL},
	[T_TYPE_EXPR]     = {"write(pcdata(tostring(",    " or '')))"},
	[T_TYPE_EXPR_RAW] = {"write(tostring(",           " or ''))"},
	[T_TYPE_INCLUDE]  = {"include('",                 "')"},
	[T_TYPE_I18N]     = {"write(pcdata(translate('",  "')))"},
	[T_TYPE_I18N_RAW] = {"write(translate('",         "'))"},
	[T_TYPE_CODE]     = {NULL,                        " "},
	[T_TYPE_EOF]      = {NULL,                        NULL},
};

static struct template_parser * template_init(struct template_parser *parser)
{
	parser->off = parser->data;
	parser->cur_chunk.type = T_TYPE_INIT;
	parser->cur_chunk.s    = parser->data;
	parser->cur_chunk.e    = parser->data;

	return parser;
}

struct template_parser * template_open(const char *file)
{
	int fd = -1;
	struct stat s;
	struct template_parser *parser;

	if (!(parser = calloc(1, sizeof(*parser))))
		goto err;

	parser->file = file;

	fd = open(file, O_RDONLY|O_CLOEXEC);
	if (fd < 0)
		goto err;

	if (fstat(fd, &s))
		goto err;

	parser->size = s.st_size;
	parser->data = mmap(NULL, parser->size, PROT_READ, MAP_PRIVATE,
						fd, 0);

	close(fd);
	fd = -1;

	if (parser->data == MAP_FAILED)
		goto err;

	return template_init(parser);

err:
	if (fd >= 0)
		close(fd);
	template_close(parser);
	return NULL;
}

struct template_parser * template_string(const char *str, size_t len)
{
	struct template_parser *parser;

	if (!(parser = calloc(1, sizeof(*parser))))
		goto err;

	parser->size = len;
	parser->data = (char *)str;

	return template_init(parser);

err:
	template_close(parser);
	return NULL;
}

void template_close(struct template_parser *parser)
{
	if (!parser)
		return;

	free(parser->lua_chunk);

	/* if file is not set, we were parsing a string */
	if (parser->file) {
		if ((parser->data != NULL) && (parser->data != MAP_FAILED))
			munmap(parser->data, parser->size);
	}

	free(parser);
}

static void template_text(struct template_parser *parser, const char *e)
{
	const char *s = parser->off;

	if (s < (parser->data + parser->size)) {
		if (parser->strip_after) {
			while ((s < e) && isspace(s[0]))
				s++;
		}

		parser->cur_chunk.type = T_TYPE_TEXT;
	} else {
		parser->cur_chunk.type = T_TYPE_EOF;
	}

	parser->cur_chunk.line = parser->line;
	parser->cur_chunk.s = s;
	parser->cur_chunk.e = e;
}

static void template_code(struct template_parser *parser, const char *e)
{
	const char *s = parser->off;

	parser->strip_before = false;
	parser->strip_after = false;

	if (s < e && s[0] == '-') {
		parser->strip_before = true;
		s++;
	}

	if (s < e && e[-1] == '-') {
		parser->strip_after = true;
		e--;
	}

	switch (*s) {
	/* comment */
	case '#':
		s++;
		parser->cur_chunk.type = T_TYPE_COMMENT;
		break;

	/* include */
	case '+':
		s++;
		parser->cur_chunk.type = T_TYPE_INCLUDE;
		break;

	/* translate */
	case ':':
		s++;
		parser->cur_chunk.type = T_TYPE_I18N;
		break;

	/* translate raw */
	case '_':
		s++;
		parser->cur_chunk.type = T_TYPE_I18N_RAW;
		break;

	/* expr */
	case '|':
		s++;
		parser->cur_chunk.type = T_TYPE_EXPR;
		break;

	/* expr raw */
	case '=':
		s++;
		parser->cur_chunk.type = T_TYPE_EXPR_RAW;
		break;

	/* code */
	default:
		parser->cur_chunk.type = T_TYPE_CODE;
	}

	parser->cur_chunk.line = parser->line;
	parser->cur_chunk.s = s;
	parser->cur_chunk.e = e;
}

static void luastr_escape(struct template_buffer *out, const char *s, const char *e)
{
	for (const char *ptr = s; ptr < e; ptr++) {
		switch (*ptr) {
		case '\\':
			buf_append(out, "\\\\", 2);
			break;

		case '\'':
			buf_append(out, "\\\'", 2);
			break;

		case '\n':
			buf_append(out, "\\n", 2);
			break;

		default:
			buf_putchar(out, *ptr);
		}
	}
}

static struct template_buffer * template_format_chunk(struct template_parser *parser)
{
	const char *p;
	const char *head, *tail;
	struct template_chunk *c = &parser->prv_chunk;

	if (parser->strip_before && c->type == T_TYPE_TEXT) {
		while ((c->e > c->s) && isspace(c->e[-1]))
			c->e--;
	}

	/* empty chunk */
	if (c->type == T_TYPE_EOF)
		return NULL;

	struct template_buffer *buf = buf_init(c->e - c->s);
	if (!buf)
		return NULL;

	if (c->e > c->s) {
		if ((head = gen_code[c->type][0]) != NULL)
			buf_append(buf, head, strlen(head));

		switch (c->type) {
		case T_TYPE_TEXT:
		case T_TYPE_INCLUDE:
		case T_TYPE_I18N:
		case T_TYPE_I18N_RAW:
			luastr_escape(buf, c->s, c->e);
			break;

		case T_TYPE_EXPR:
		case T_TYPE_EXPR_RAW:
			buf_append(buf, c->s, c->e - c->s);
			for (p = c->s; p < c->e; p++)
				parser->line += (*p == '\n');
			break;

		case T_TYPE_CODE:
			buf_append(buf, c->s, c->e - c->s);
			for (p = c->s; p < c->e; p++)
				parser->line += (*p == '\n');
			break;

		case T_TYPE_INIT:
		case T_TYPE_COMMENT:
		case T_TYPE_EOF:
			break;
		}

		if ((tail = gen_code[c->type][1]) != NULL)
			buf_append(buf, tail, strlen(tail));
	}

	return buf;
}

const char * template_reader(lua_State *L __attribute__((unused)), void *ud, size_t *sz)
{
	struct template_parser *parser = ud;

	/* free previous chunk */
	free(parser->lua_chunk);
	parser->lua_chunk = NULL;

	while (true) {
		int rem = parser->size - (parser->off - parser->data);
		char *tag;

		parser->prv_chunk = parser->cur_chunk;

		/* before tag */
		if (!parser->in_expr) {
			if ((tag = memmem(parser->off, rem, "<%", 2)) != NULL) {
				template_text(parser, tag);
				parser->off = tag + 2;
				parser->in_expr = 1;
			} else {
				template_text(parser, parser->data + parser->size);
				parser->off = parser->data + parser->size;
			}
		}

		/* inside tag */
		else {
			if ((tag = memmem(parser->off, rem, "%>", 2)) != NULL) {
				template_code(parser, tag);
				parser->off = tag + 2;
				parser->in_expr = 0;
			} else {
				/* unexpected EOF */
				template_code(parser, parser->data + parser->size);

				*sz = 1;
				return "\033";
			}
		}

		struct template_buffer *buf = template_format_chunk(parser);
		if (!buf)
			return NULL;

		*sz = buf_length(buf);
		if (*sz) {
			parser->lua_chunk = buf_destroy(buf);
			return parser->lua_chunk;
		}
	}
}

int template_error(lua_State *L, struct template_parser *parser)
{
	const char *err = luaL_checkstring(L, -1);
	const char *off = parser->prv_chunk.s;
	const char *ptr;
	char msg[1024];
	int line = 0;
	int chunkline = 0;

	if ((ptr = memmem(err, strlen(err), "]:", 2)) != NULL) {
		chunkline = atoi(ptr + 2) - parser->prv_chunk.line;

		while (*ptr) {
			if (*ptr++ == ' ') {
				err = ptr;
				break;
			}
		}
	}

	if (memmem(err, strlen(err), "'char(27)'", 10) != NULL) {
		off = parser->data + parser->size;
		err = "'%>' expected before end of file";
		chunkline = 0;
	}

	for (ptr = parser->data; ptr < off; ptr++) {
		if (*ptr == '\n')
			line++;
	}

	snprintf(msg, sizeof(msg), "Syntax error in %s:%d: %s",
			parser->file ?: "[string]", line + chunkline, err ?: "(unknown error)");

	lua_pushnil(L);
	lua_pushinteger(L, line + chunkline);
	lua_pushstring(L, msg);

	return 3;
}
