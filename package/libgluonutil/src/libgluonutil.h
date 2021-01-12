/*
  Copyright (c) 2016, Matthias Schiffer <mschiffer@universe-factory.net>
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


#ifndef _LIBGLUON_LIBGLUON_H_
#define _LIBGLUON_LIBGLUON_H_

#include <net/if.h>
#include <netinet/in.h>
#include <stdbool.h>


char * gluonutil_read_line(const char *filename);
char * gluonutil_get_sysconfig(const char *key);
char * gluonutil_get_node_id(void);

enum gluonutil_interface_type {
	GLUONUTIL_INTERFACE_TYPE_UNKNOWN,
	GLUONUTIL_INTERFACE_TYPE_WIRED,
	GLUONUTIL_INTERFACE_TYPE_WIRELESS,
	GLUONUTIL_INTERFACE_TYPE_TUNNEL,
};

void gluonutil_get_interface_lower(char out[IF_NAMESIZE], const char *ifname);
char * gluonutil_get_interface_address(const char *ifname);
enum gluonutil_interface_type gluonutil_get_interface_type(const char *ifname);

bool gluonutil_get_node_prefix6(struct in6_addr *prefix);

struct json_object * gluonutil_wrap_string(const char *str);
struct json_object * gluonutil_wrap_and_free_string(char *str);

bool gluonutil_has_domains(void);
char * gluonutil_get_domain(void);
char * gluonutil_get_primary_domain(void);
struct json_object * gluonutil_load_site_config(void);

#endif /* _LIBGLUON_LIBGLUON_H_ */
