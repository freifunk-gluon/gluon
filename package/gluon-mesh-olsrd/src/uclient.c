/*
  Copyright (c) 2017, Jan-Philipp Litza <janphilipp@litza.de>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#include "uclient.h"

#include <libubox/blobmsg.h>
#include <libubox/uloop.h>

#include <limits.h>
#include <stdio.h>


#define TIMEOUT_MSEC 300000

static const char *const user_agent = "OLSRDHelper.so (using libuclient)";


const char *uclient_get_errmsg(int code) {
	static char http_code_errmsg[16];
	if (code & UCLIENT_ERROR_STATUS_CODE) {
		snprintf(http_code_errmsg, 16, "HTTP error %d",
			code & (~UCLIENT_ERROR_STATUS_CODE));
		return http_code_errmsg;
	}
	switch(code) {
	case UCLIENT_ERROR_CONNECT:
		return "Connection failed";
	case UCLIENT_ERROR_TIMEDOUT:
		return "Connection timed out";
	case UCLIENT_ERROR_REDIRECT_FAILED:
		return "Failed to redirect";
	case UCLIENT_ERROR_TOO_MANY_REDIRECTS:
		return "Too many redirects";
	case UCLIENT_ERROR_CONNECTION_RESET_PREMATURELY:
		return "Connection reset prematurely";
	case UCLIENT_ERROR_SIZE_MISMATCH:
		return "Incorrect file size";
	case UCLIENT_ERROR_NOT_JSON:
		return "Response not json";
	default:
		return "Unknown error";
	}
}


static void request_done(struct uclient *cl, int err_code) {
	uclient_data(cl)->err_code = err_code;
	uclient_disconnect(cl);
	uloop_end();
}


static void header_done_cb(struct uclient *cl) {
	const struct blobmsg_policy policy = {
		.name = "content-length",
		.type = BLOBMSG_TYPE_STRING,
	};
	struct blob_attr *tb_len;

	if (uclient_data(cl)->retries < 10) {
		int ret = uclient_http_redirect(cl);
		if (ret < 0) {
			request_done(cl, UCLIENT_ERROR_REDIRECT_FAILED);
			return;
		}
		if (ret > 0) {
			uclient_data(cl)->retries++;
			return;
		}
	}

	switch (cl->status_code) {
	case 200:
		break;
	case 301:
	case 302:
	case 307:
		request_done(cl, UCLIENT_ERROR_TOO_MANY_REDIRECTS);
		return;
	default:
		request_done(cl, UCLIENT_ERROR_STATUS_CODE | cl->status_code);
		return;
	}

	blobmsg_parse(&policy, 1, &tb_len, blob_data(cl->meta), blob_len(cl->meta));
	if (tb_len) {
		char *endptr;

		errno = 0;
		unsigned long long val = strtoull(blobmsg_get_string(tb_len), &endptr, 10);
		if (!errno && !*endptr && val <= SSIZE_MAX) {
			if (uclient_data(cl)->length >= 0 && uclient_data(cl)->length != (ssize_t)val) {
				request_done(cl, UCLIENT_ERROR_SIZE_MISMATCH);
				return;
			}

			uclient_data(cl)->length = val;
		}
	}
}


static void eof_cb(struct uclient *cl) {
	request_done(cl, cl->data_eof ? 0 : UCLIENT_ERROR_CONNECTION_RESET_PREMATURELY);
	if (cl->data_eof) {
		uclient_data(cl)->eof(cl);
	}
}


ssize_t uclient_read_account(struct uclient *cl, char *buf, int len) {
	struct uclient_data *d = uclient_data(cl);
	int r = uclient_read(cl, buf, len);

	if (r >= 0) {
		d->downloaded += r;

		if (d->length >= 0 && d->downloaded > d->length) {
			request_done(cl, UCLIENT_ERROR_SIZE_MISMATCH);
			return -1;
		}
	}

	return r;
}

// src https://github.com/curl/curl/blob/2610142139d14265ed9acf9ed83cdf73d6bb4d05/lib/escape.c

/* Portable character check (remember EBCDIC). Do not use isalnum() because
   its behavior is altered by the current locale.
   See https://datatracker.ietf.org/doc/html/rfc3986#section-2.3
*/
bool Curl_isunreserved(unsigned char in)
{
  switch(in) {
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
    case 'a': case 'b': case 'c': case 'd': case 'e':
    case 'f': case 'g': case 'h': case 'i': case 'j':
    case 'k': case 'l': case 'm': case 'n': case 'o':
    case 'p': case 'q': case 'r': case 's': case 't':
    case 'u': case 'v': case 'w': case 'x': case 'y': case 'z':
    case 'A': case 'B': case 'C': case 'D': case 'E':
    case 'F': case 'G': case 'H': case 'I': case 'J':
    case 'K': case 'L': case 'M': case 'N': case 'O':
    case 'P': case 'Q': case 'R': case 'S': case 'T':
    case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z':
    case '-': case '.': case '_': case '~':
      return true;
    default:
      break;
  }
  return false;
}

char *curl_easy_escape(const char *string, int inlength)
{
  size_t length;

  if (inlength < 0)
    return NULL;

  length = (inlength ? (size_t)inlength : strlen(string));
  if (!length)
    return strdup("");

	char * out = malloc((length * 3) + 1);

	if (!out)
		return NULL;

	size_t offset = 0;

	// this isn't pretending like we're complying to any spec other than urlencode, thx
	int slashes = 0;

  while (length--) {
    unsigned char in = *string; /* we need to treat the characters unsigned */

		if (slashes == 3) {
			if (Curl_isunreserved(in)) {
				/* append this */
				out[offset] = in;
				offset++;
			} else {
				/* encode it */
				if (snprintf(out + offset, 4, "%%%02X", in) != 3) {
					free(out);
					return NULL;
				}

				offset += 3;
			}
		} else {
			out[offset] = in;
			offset++;

			if (in == '/') {
				slashes++;
			}
		}

    string++;
  }

	out[offset] = '\0';

  return out;
}

int get_url(const char *user_url, void (*read_cb)(struct uclient *cl), void (*eof2_cb)(struct uclient *cl), void *cb_data, ssize_t len) {
	char *url = curl_easy_escape(user_url, 0);
	if (!url)
		return UCLIENT_ERROR_CONNECT;

	struct uclient_data d = { .custom = cb_data, .length = len, .eof = eof2_cb };
	struct uclient_cb cb = {
		.header_done = header_done_cb,
		.data_read = read_cb,
		.data_eof = eof_cb,
		.error = request_done,
	};

	struct uclient *cl = uclient_new(url, NULL, &cb);
	if (!cl)
		goto err;

	cl->priv = &d;
	if (uclient_set_timeout(cl, TIMEOUT_MSEC))
		goto err;
	if (uclient_connect(cl))
		goto err;
	if (uclient_http_set_request_type(cl, "GET"))
		goto err;
	if (uclient_http_reset_headers(cl))
		goto err;
	if (uclient_http_set_header(cl, "User-Agent", user_agent))
		goto err;
	if (uclient_request(cl))
		goto err;
	uloop_run();
	uclient_free(cl);
	free(url);

	if (!d.err_code && d.length >= 0 && d.downloaded != d.length)
		return UCLIENT_ERROR_SIZE_MISMATCH;

	return d.err_code;

err:
	if (cl)
		uclient_free(cl);

	free(url);

	return UCLIENT_ERROR_CONNECT;
}
