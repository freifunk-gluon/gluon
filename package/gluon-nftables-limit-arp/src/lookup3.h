#include <stdint.h>     /* defines uint32_t etc */

uint32_t hashword(
const uint32_t *k,                   /* the key, an array of uint32_t values */
size_t          length,               /* the length of the key, in uint32_ts */
uint32_t        initval);         /* the previous hash, or an arbitrary value */
