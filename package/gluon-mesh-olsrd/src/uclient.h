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
#pragma once


#include <libubox/uclient.h>
#include <sys/types.h>


struct uclient_data {
	/* data that can be passed in by caller and used in custom callbacks */
	void *custom;
	/* data used by uclient callbacks */
	int retries;
	int err_code;
	ssize_t downloaded;
	ssize_t length;
	void (*eof)(struct uclient *cl);
};

enum uclient_own_error_code {
	UCLIENT_ERROR_REDIRECT_FAILED = 32,
	UCLIENT_ERROR_TOO_MANY_REDIRECTS,
	UCLIENT_ERROR_CONNECTION_RESET_PREMATURELY,
	UCLIENT_ERROR_SIZE_MISMATCH,
	UCLIENT_ERROR_STATUS_CODE = 1024,
	UCLIENT_ERROR_NOT_JSON = 2048
};

inline struct uclient_data * uclient_data(struct uclient *cl) {
	return (struct uclient_data *)cl->priv;
}

inline void * uclient_get_custom(struct uclient *cl) {
	return uclient_data(cl)->custom;
}


ssize_t uclient_read_account(struct uclient *cl, char *buf, int len);

int get_url(const char *url, void (*read_cb)(struct uclient *cl), void (*eof2_cb)(struct uclient *cl), void *cb_data, ssize_t len);
const char *uclient_get_errmsg(int code);
