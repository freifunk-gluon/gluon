#include <stdint.h>
#include <linux/if_ether.h>

#define F_MAC "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx"
#define F_MAC_LEN 17
#define F_MAC_IGN "%*2x:%*2x:%*2x:%*2x:%*2x:%*2x"
#define F_MAC_VAR(var) (var)[0], (var)[1], (var)[2], (var)[3], (var)[4], (var)[5]
#define F_MAC_VAR_REF(var) &(var)[0], &(var)[1], &(var)[2], &(var)[3], &(var)[4], &(var)[5]

typedef uint8_t macaddr_t[ETH_ALEN];
