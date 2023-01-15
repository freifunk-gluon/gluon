/* SPDX-License-Identifier: MIT */
/* batman-adv helpers functions library
 *
 * Copyright (c) 2017, Sven Eckelmann <sven@narfation.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef _BATADV_GENL_H_
#define _BATADV_GENL_H_

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>
#include <stddef.h>
#include <stdbool.h>

#include "batman_adv.h"

/**
 * struct batadv_nlquery_opts - internal state for batadv_genl_query()
 *
 * This structure should be used as member of a struct which tracks the state
 * for the callback. The macro batadv_container_of can be used to convert the
 * arg pointer from batadv_nlquery_opts to the member which contains this
 * struct.
 */
struct batadv_nlquery_opts {
	/** @err: current error  */
	int err;
};

/**
 * BATADV_ARRAY_SIZE() - Get number of items in static array
 * @x: array with known length
 *
 * Return:  number of items in array
 */
#ifndef BATADV_ARRAY_SIZE
#define BATADV_ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
#endif

/**
 * batadv_container_of() - Calculate address of object that contains address ptr
 * @ptr: pointer to member variable
 * @type: type of the structure containing ptr
 * @member: name of the member variable in struct @type
 *
 * Return: @type pointer of object containing ptr
 */
#ifndef batadv_container_of
#define batadv_container_of(ptr, type, member) __extension__ ({ \
	const __typeof__(((type *)0)->member) *__pmember = (ptr); \
	(type *)((char *)__pmember - offsetof(type, member)); })
#endif

/**
 * batadv_genl_missing_attrs() - Check whether @attrs is missing mandatory
 *  attribute
 * @attrs: attributes which was parsed by nla_parse()
 * @mandatory: list of required attributes
 * @num: number of required attributes in @mandatory
 *
 * Return: Return true when a attribute is missing, false otherwise
 */
static inline bool batadv_genl_missing_attrs(struct nlattr *attrs[],
		const enum batadv_nl_attrs mandatory[], size_t num) {
	size_t i;

	for (i = 0; i < num; i++) {
		if (!attrs[mandatory[i]])
			return true;
	}

	return false;
}

extern struct nla_policy batadv_genl_policy[];

int batadv_genl_query(const char *mesh_iface, enum batadv_nl_commands nl_cmd,
		nl_recvmsg_msg_cb_t callback, int flags,
		struct batadv_nlquery_opts *query_opts);

#endif /* _BATADV_GENL_H_ */
