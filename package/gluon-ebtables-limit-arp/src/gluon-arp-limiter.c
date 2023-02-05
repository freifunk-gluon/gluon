// SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "addr_store.h"
#include "gluon-arp-limiter.h"
#include "mac.h"

#define BATCTL_DC "/usr/sbin/batctl dc -H -n"
#define BATCTL_TL "/usr/sbin/batctl tl -H -n"
#define EBTABLES "/usr/sbin/ebtables"

#define BUILD_BUG_ON(check) ((void)sizeof(int[1-2*!!(check)]))

static struct addr_store ip_store;
static struct addr_store mac_store;

int clock;

char *addr_mac_ntoa(void *addr)
{
	return mac_ntoa((struct mac_addr *)addr);
}

char *addr_inet_ntoa(void *addr)
{
	return inet_ntoa(*((struct in_addr *)addr));
}

static void ebt_ip_call(char *mod, struct in_addr ip)
{
	char str[196];
	int ret;

	snprintf(str, sizeof(str),
			EBTABLES " %s ARP_LIMIT_DATCHECK -p ARP --arp-ip-dst %s -j mark --mark-or 0x2 --mark-target RETURN",
			mod, inet_ntoa(ip));

	ret = system(str);
	if (ret)
		fprintf(stderr,
			"%i: Calling ebtables for DAT failed with status %i\n",
			clock, ret);
}

static void ip_node_destructor(struct addr_list *node)
{
	struct in_addr *ip = (struct in_addr *)node->addr;

	ebt_ip_call("-D", *ip);
}

static void ebt_mac_limit_call(char *mod, struct mac_addr *mac)
{
	char str[128];
	int ret;

	snprintf(str, sizeof(str),
			EBTABLES " %s ARP_LIMIT_TLCHECK --source %s --limit 6/min --limit-burst 50 -j RETURN",
			mod, mac_ntoa(mac));

	ret = system(str);
	if (ret)
		fprintf(stderr,
			"%i: Calling ebtables for TL failed with status %i\n",
			clock, ret);
}

static void ebt_mac_ret_call(char *mod, struct mac_addr *mac, int add)
{
	char str[128];
	int ret;

	snprintf(str, sizeof(str),
			EBTABLES " %s ARP_LIMIT_TLCHECK %s --source %s -j DROP",
			mod, add ? "2" : "", mac_ntoa(mac));

	ret = system(str);
	if (ret)
		fprintf(stderr,
			"%i: Calling ebtables for TL failed with status %i\n",
			clock, ret);
}

static void ebt_mac_call(char *mod, struct mac_addr *mac)
{
	if (!strncmp(mod, "-D", strlen(mod))) {
		ebt_mac_ret_call(mod, mac, 0);
		ebt_mac_limit_call(mod, mac);
	} else {
		ebt_mac_limit_call(mod, mac);
		ebt_mac_ret_call(mod, mac, 1);
	}
}

static void mac_node_destructor(struct addr_list *node)
{
	struct mac_addr *mac = (struct mac_addr *)node->addr;

	ebt_mac_call("-D", mac);
}

static int dat_parse_line(const char *line, struct in_addr *ip)
{
	int ret;
	char *p;
	char *tok;

	p = strpbrk(line, "0123456789");
	if (!p) {
		fprintf(stderr, "Error: Can't find integer in: %s\n", line);
		return -EINVAL;
	}

	tok = strtok(p, " ");
	if (!tok) {
		fprintf(stderr, "Error: Can't find end of string': %s\n", line);
		return -EINVAL;
	}

	ret = inet_aton(p, ip);
	if (!ret) {
		fprintf(stderr, "Error: inet_aton failed on: %s\n", p);
		return -EINVAL;
	}

	return 0;
}

static void ebt_add_ip(struct in_addr ip)
{
	int ret = addr_store_add(&ip, &ip_store);

	/* already stored or out-of-memory */
	if (ret)
		return;

	ebt_ip_call("-I", ip);
}

static void ebt_add_mac(struct mac_addr *mac)
{
	int ret = addr_store_add(mac, &mac_store);

	/* already stored or out-of-memory */
	if (ret)
		return;

	ebt_mac_call("-I", mac);
}

static void ebt_dat_update(void)
{
	FILE *fp;
	char line[256];
	char *pline;
	int ret;
	struct in_addr ip;

	fp = popen(BATCTL_DC, "r");
	if (!fp) {
		fprintf(stderr, "%i: Error: Could not call batctl dc\n", clock);
		return;
	}
	
	while (1) {
		pline = fgets(line, sizeof(line), fp);
		if (!pline) {
			if (!feof(fp))
				fprintf(stderr, "%i: Error: fgets() failed\n", clock);
			break;
		}

		ret = dat_parse_line(line, &ip);
		if (ret < 0) {
			fprintf(stderr, "%i: Error: Parsing line failed\n",
				clock);
			break;
		}

		ebt_add_ip(ip);
	}

	pclose(fp);
}

static int tl_parse_line(char *line, struct mac_addr *mac)
{
	int ret;
	char *p;
	char *tok;

	p = strpbrk(line, "0123456789abcdef");
	if (!p) {
		fprintf(stderr, "Error: Can't find hex in: %s\n", line);
		return -EINVAL;
	}

	tok = strtok(p, " ");
	if (!tok) {
		fprintf(stderr, "Error: Can't find end of string': %s\n", line);
		return -EINVAL;
	}

	ret = mac_aton(p, mac);
	if (!ret) {
		fprintf(stderr, "Error: mac_aton failed on: %s\n", p);
		return -EINVAL;
	}

	return 0;
}

static void ebt_tl_update(void)
{
	FILE *fp;
	char line[256];
	char *pline;
	int ret;
	struct mac_addr mac;

	fp = popen(BATCTL_TL, "r");
	if (!fp) {
		fprintf(stderr, "%i: Error: Could not call batctl tl\n", clock);
		return;
	}

	while (1) {
		pline = fgets(line, sizeof(line), fp);
		if (!pline) {
			if (!feof(fp))
				fprintf(stderr, "%i: Error: fgets() failed\n", clock);
			break;
		}

		ret = tl_parse_line(line, &mac);
		if (ret < 0) {
			fprintf(stderr, "%i: Error: Parsing line failed\n",
				clock);
			break;
		}

		if (mac_is_multicast(&mac))
			continue;

		ebt_add_mac(&mac);
	}

	pclose(fp);
}

static void ebt_dat_flush(void)
{
	int ret = system(EBTABLES " -F ARP_LIMIT_DATCHECK");

	if (ret)
		fprintf(stderr, "Error flushing ARP_LIMIT_DATCHECK\n");
}

static void ebt_tl_flush(void)
{
	int ret = system(EBTABLES " -F ARP_LIMIT_TLCHECK");

	if (ret)
		fprintf(stderr, "Error flushing ARP_LIMIT_TLCHECK\n");
}

int main(int argc, char *argv[])
{
	ebt_dat_flush();
	ebt_tl_flush();

	/* necessary alignment for hashword() */
	BUILD_BUG_ON(sizeof(struct in_addr) % sizeof(uint32_t) != 0);
	BUILD_BUG_ON(sizeof(struct mac_addr) % sizeof(uint32_t) != 0);

	addr_store_init(sizeof(struct in_addr), &ip_node_destructor,
			addr_inet_ntoa, &ip_store);
	addr_store_init(sizeof(struct mac_addr), &mac_node_destructor,
			addr_mac_ntoa, &mac_store);

	while (1) {
		ebt_dat_update();
		addr_store_cleanup(&ip_store);

		ebt_tl_update();
		addr_store_cleanup(&mac_store);

		sleep(30);
		clock++;
	}

	return 0;
}
