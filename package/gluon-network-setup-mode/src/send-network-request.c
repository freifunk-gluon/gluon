/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * Utility for performing remote setup-mode activation
 *
 * Copyright (c) David Bauer <mail@david-bauer.net>
 */

#define _GNU_SOURCE

#include <arpa/inet.h>
#include <errno.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "gluon-remote-setup-mode.h"

static const uint8_t destination[] = { REMOTE_SETUP_MODE_DST_MAC };
static const uint8_t source[] = { REMOTE_SETUP_MODE_SRC_MAC };
static const uint8_t type[] = { REMOTE_SETUP_MODE_ETHERTYPE };
/* Command including its terminating NUL byte */
static const char command[] = REMOTE_SETUP_MODE_DATA_CMD_SETUP;

int main(int argc, char *argv[])
{
	struct sockaddr_ll sll = {
		.sll_family = AF_PACKET,
	};
	/* Padded to the minimum frame length, as not all drivers pad short frames */
	uint8_t buf[ETH_ZLEN] = { 0 };
	int last_errno = 0;
	int s_fd;

	memcpy(&buf[REMOTE_SETUP_MODE_DST_MAC_OFFSET], destination, sizeof(destination));
	memcpy(&buf[REMOTE_SETUP_MODE_SRC_MAC_OFFSET], source, sizeof(source));
	memcpy(&buf[REMOTE_SETUP_MODE_ETHERTYPE_OFFSET], type, sizeof(type));
	memcpy(&buf[REMOTE_SETUP_MODE_DATA_CMD_OFFSET], command, sizeof(command));

	if (argc != 2 || !strcmp("help", argv[1])) {
		fprintf(stderr, "Usage: %s <ifname>\n", argv[0]);
		return 1;
	}

	sll.sll_ifindex = if_nametoindex(argv[1]);
	if (!sll.sll_ifindex) {
		fprintf(stderr, "Interface %s not found\n", argv[1]);
		return 1;
	}

	s_fd = socket(AF_PACKET, SOCK_RAW, 0);
	if (s_fd < 0) {
		fprintf(stderr, "Socket error: %m\n");
		return 1;
	}

	printf("Sending setup-mode request on %s, power-cycle the node now (Ctrl-C to stop)\n", argv[1]);
	fflush(stdout);
	while (1) {
		/* Keep sending on errors, e.g. while the link is down as the node
		 * is power-cycled, but only report changes of the error */
		if (sendto(s_fd, buf, sizeof(buf), 0, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
			int err = errno;

			if (err != last_errno)
				fprintf(stderr, "Error sending packet, retrying: %s\n", strerror(err));
			last_errno = err;
		} else {
			if (last_errno)
				fprintf(stderr, "Sending packets again\n");
			last_errno = 0;
		}

		usleep(REMOTE_SETUP_MODE_TX_INTERVAL_MS * 1000);
	}
}
