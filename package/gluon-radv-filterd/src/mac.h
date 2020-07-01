#pragma once

#include <stdint.h>
#include <string.h>
#include <linux/if_ether.h>

#define F_MAC "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx"
#define F_MAC_LEN 17
#define F_MAC_VAR(var) \
	(var).ether_addr_octet[0], (var).ether_addr_octet[1], \
	(var).ether_addr_octet[2], (var).ether_addr_octet[3], \
	(var).ether_addr_octet[4], (var).ether_addr_octet[5]
#define F_MAC_VAR_REF(var) \
	&(var).ether_addr_octet[0], &(var).ether_addr_octet[1], \
	&(var).ether_addr_octet[2], &(var).ether_addr_octet[3], \
	&(var).ether_addr_octet[4], &(var).ether_addr_octet[5]
#define MAC2ETHER(_ether, _mac) memcpy((_ether).ether_addr_octet, \
				       (_mac), ETH_ALEN)

#define ether_addr_equal(_a, _b) (memcmp((_a).ether_addr_octet, \
					 (_b).ether_addr_octet, ETH_ALEN) == 0)
