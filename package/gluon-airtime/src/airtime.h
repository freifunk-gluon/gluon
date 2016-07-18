#pragma once

#include <stdint.h>

struct airtime_time {
	uint64_t current;
	uint64_t offset;
};

struct airtime_result {
	uint32_t frequency;
	uint8_t  noise;
	struct airtime_time active_time;
	struct airtime_time busy_time;
	struct airtime_time rx_time;
	struct airtime_time tx_time;
};

struct airtime {
	struct airtime_result radio0;
	struct airtime_result radio1;
};

struct airtime* get_airtime(const char *radio0, const char *radio1);
