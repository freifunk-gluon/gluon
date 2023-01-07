// SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
// SPDX-License-Identifier: GPL-2.0-or-later

#ifndef _MAC_H_
#define _MAC_H_

struct mac_addr {
	/* 8 instead of 6 for multiples of uint32_t for hashword() */
	unsigned char storage[8];
};

int mac_aton(const char *cp, struct  mac_addr *mac);
char *mac_ntoa(struct mac_addr *mac);

static inline int mac_is_multicast(struct mac_addr *addr)
{
	return addr->storage[0] & 0x01;
}

#endif /* _MAC_H_ */
