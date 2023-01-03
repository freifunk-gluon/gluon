// SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
// SPDX-License-Identifier: GPL-2.0-or-later

#ifndef _ADDR_STORE_H_
#define _ADDR_STORE_H_

#define ADDR_STORE_NUM_BUCKETS 32

struct addr_list {
	struct addr_list *next;
	int tic;
	char addr[0];
};

struct addr_store {
	struct addr_list *buckets[ADDR_STORE_NUM_BUCKETS];
	size_t addr_len;
	void (*destructor)(struct addr_list *);
	char *(*ntoa)(void *);
};

int addr_store_init(size_t addr_len,
		void (*destructor)(struct addr_list *),
		char *(*ntoa)(void *),
		struct addr_store *store);
int addr_store_add(void *addr, struct addr_store *store);
void addr_store_cleanup(struct addr_store *store);

#endif /* _ADDR_STORE_H_ */
