// SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "addr_store.h"
#include "gluon-arp-limiter.h"
#include "lookup3.h"

static struct addr_list *addr_node_alloc(void *addr,
		struct addr_store *store)
{
	struct addr_list *node;
	size_t addr_len = store->addr_len;

	node = malloc(sizeof(struct addr_list) + addr_len);
	if (!node)
		return NULL;

	memcpy(node->addr, addr, addr_len);
	node->next = NULL;
	node->tic = clock;

	return node;
}

static struct addr_list *addr_list_search(void *addr,
		size_t addr_len,
		struct addr_list *list)
{
	struct addr_list *node = list;
	struct addr_list *ret = NULL;

	if (!node)
		goto out;

	do {
		// Found it!
		if (!memcmp(node->addr, addr, addr_len)) {
			ret = node;
			break;
		}

		node = node->next;
	} while (node);

out:
	return ret;
}

static void addr_list_add(struct addr_list *node, struct addr_list **list)
{
	node->next = *list;
	*list = node;
}

static struct addr_list **addr_store_get_bucket(void *addr,
						struct addr_store *store)
{
	int len = store->addr_len / sizeof(uint32_t);
	int idx;
	uint32_t ret;

	ret = hashword(addr, len, 0);
	idx = ret % ADDR_STORE_NUM_BUCKETS;

	return &store->buckets[idx];
}

int addr_store_add(void *addr, struct addr_store *store)
{
	struct addr_list **bucket = addr_store_get_bucket(addr, store);
	struct addr_list *node = addr_list_search(addr, store->addr_len,
			*bucket);

	if (node) {
		node->tic = clock;
		return -EEXIST;
	}

	node = addr_node_alloc(addr, store);
	if (!node) {
		printf("Error: Out of memory\n");
		return -ENOMEM;
	}

	addr_list_add(node, bucket);
	return 0;
}

int addr_store_init(size_t addr_len,
		void (*destructor)(struct addr_list *),
		char *(*ntoa)(void *),
		struct addr_store *store)
{
	int i;

	store->addr_len = addr_len;
	store->destructor = destructor;
	store->ntoa = ntoa;

	for (i = 0; i < ADDR_STORE_NUM_BUCKETS; i++)
		store->buckets[i] = NULL;

	return 0;
}

static char *addr_ntoa(void *addr, struct addr_store *store)
{
	return store->ntoa(addr);
}

static void addr_store_dump(struct addr_store *store)
{
	int i;
	struct addr_list *node;

	for (i = 0; i < ADDR_STORE_NUM_BUCKETS; i++) {
		node = store->buckets[i];

		if (node)
			printf("Bucket #%i:\n", i);

		while (node) {
			printf("\t%s\n", addr_ntoa(node->addr, store));
			node = node->next;
		}
	}
}

void addr_store_cleanup(struct addr_store *store)
{
	struct addr_list *node, *prev;
	int i;

	for (i = 0; i < ADDR_STORE_NUM_BUCKETS; i++) {
		node = store->buckets[i];
		prev = NULL;

		while (node) {
			if (node->tic != clock) {
				store->destructor(node);

				if (prev) {
					prev->next = node->next;
					free(node);
					node = prev->next;
				} else {
					store->buckets[i] = node->next;
					free(node);
					node = store->buckets[i];
				}
			} else {
				prev = node;
				node = node->next;
			}
		}
	}

	addr_store_dump(store);
}
