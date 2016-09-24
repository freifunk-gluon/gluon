/*
 * Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
 *
 * Marek Lindner <mareklindner@neomailbox.ch>, Andrew Lunn <andrew@lunn.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of version 2 of the GNU General Public
 * License as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA
 *
 */

#ifndef _BATADV_NETLINK_H
#define _BATADV_NETLINK_H

#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <stddef.h>

struct nlquery_opts {
	int err;
};

#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))

#ifndef container_of
#define container_of(ptr, type, member) __extension__ ({ \
	const __typeof__(((type *)0)->member) *__pmember = (ptr); \
	(type *)((char *)__pmember - offsetof(type, member)); })
#endif

int netlink_query_common(const char *mesh_iface, uint8_t nl_cmd,
			 nl_recvmsg_msg_cb_t callback,
			 struct nlquery_opts *query_opts);
int missing_mandatory_attrs(struct nlattr *attrs[],  const int mandatory[],
			    size_t num);

extern struct nla_policy batadv_netlink_policy[];

#endif /* _BATADV_NETLINK_H */
