// SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <linux/if_ether.h>
#include <stdio.h>
#include <string.h>
#include "mac.h"

#define ETH_STRLEN (sizeof("aa:bb:cc:dd:ee:ff") - 1)

char mntoa_buf[ETH_STRLEN+1];

int mac_aton(const char *cp, struct  mac_addr *mac)
{
	struct mac_addr m;
	int ret;

	if (strlen(cp) != ETH_STRLEN)
		return 0;

	memset(&m, 0, sizeof(m));

	ret = sscanf(cp, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
			&m.storage[0], &m.storage[1], &m.storage[2],
			&m.storage[3], &m.storage[4], &m.storage[5]);

	if (ret != ETH_ALEN)
		return 0;

	*mac = m;
	return 1;
}

char *mac_ntoa(struct mac_addr *mac)
{
	unsigned char *m = mac->storage;

	snprintf(mntoa_buf, sizeof(mntoa_buf),
			"%02x:%02x:%02x:%02x:%02x:%02x",
			m[0], m[1], m[2], m[3], m[4], m[5]);

	return mntoa_buf;
}
