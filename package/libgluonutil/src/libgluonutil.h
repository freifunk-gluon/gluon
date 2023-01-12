/* SPDX-FileCopyrightText: 2016 Matthias Schiffer <mschiffer@universe-factory.net> */
/* SPDX-License-Identifier: BSD-2-Clause */


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
