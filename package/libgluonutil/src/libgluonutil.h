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

#include <netinet/in.h>
#include <stdbool.h>


char * gluonutil_read_line(const char *filename);
char * gluonutil_get_sysconfig(const char *key);
char * gluonutil_get_node_id(void);
char * gluonutil_get_interface_address(const char *ifname);
bool gluonutil_get_node_prefix6(struct in6_addr *prefix);

struct json_object * gluonutil_wrap_string(const char *str);
struct json_object * gluonutil_wrap_and_free_string(char *str);

struct json_object * gluonutil_load_site_config(void);

/**
 * Get selected domain code
 *
 * - If NULL is passed to the site parameter, internally only the base part
 *   (without domain config) is loaded, which is more efficient than calling
 *   gluonutil_load_site_config() for this job only. Nevertheless if you already
 *   have an instance of a site object then you should pass it here.
 * - Returned domain code string has to be freed after use
 * - Returns NULL in case of error
 * - If a domain code is returned, it's ensured that the corresponding config
 *   in /lib/gluon/domains/ exists.
 */
char * gluonutil_get_selected_domain_code(struct json_object * site);

#endif /* _LIBGLUON_LIBGLUON_H_ */
