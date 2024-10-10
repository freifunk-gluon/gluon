/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * Utility for entering Setup_mode using network
 *
 * Copyright (c) David Bauer <mail@david-bauer.net>
 */

#include <fcntl.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <string.h>
#include <net/if.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <time.h>

#include "gluon-remote-setup-mode.h"

#define MAX_INTERFACES	64
#define BUFSIZE		1024


char destination[]				= { REMOTE_SETUP_MODE_DST_MAC };
char type[]						= { REMOTE_SETUP_MODE_ETHERTYPE };


static int bind_socket_to_device(int fd, int ifindex)
{
	struct sockaddr_ll sll = {
		.sll_family = AF_PACKET,
		.sll_ifindex = ifindex,
		.sll_protocol = htons(ETH_P_ALL)
	}; 

	if((bind(fd , (struct sockaddr *)&sll , sizeof(sll))) < 0) {
		return 1;
	}

	return 0;
}

static int should_reset(char *buf, size_t size)
{
	int should_reset;
	char *tlv_ptr;

	should_reset = 0;

	if (size < REMOTE_SETUP_MODE_DATA_CMD_OFFSET + strlen(REMOTE_SETUP_MODE_DATA_CMD_SETUP) + 1) {
		/* Length mismatch */
		return 0;
	}

	if (buf[size - 1] != 0x00) {
		/* Wrong trailer */
		return 0;
	}

	if (memcmp(destination, &buf[REMOTE_SETUP_MODE_DST_MAC_OFFSET], sizeof(destination))) {
		/* Wrong destination-etheraddr */
		return 0;
	}

	if (memcmp(type, &buf[REMOTE_SETUP_MODE_ETHERTYPE_OFFSET], sizeof(type))) {
		/* Wrong Ethertype */
		return 0;
	}

	if (strcmp(&buf[REMOTE_SETUP_MODE_DATA_CMD_OFFSET], REMOTE_SETUP_MODE_DATA_CMD_SETUP)) {
		/* Wrong Command */
		return 0;
	}

	return 1;
}

int main(int argc, char *argv[])
{
	time_t start_time, current_time;
	int ifindex[MAX_INTERFACES];
	int sockets[MAX_INTERFACES];
	char recvbuf[BUFSIZE];
	int num_interfaces;
	int received;
	int i;

	start_time = time(NULL);

	if (argc < 2) {
		fprintf(stderr, "At least one Interface name is required\n", MAX_INTERFACES);
		return 1;
	}

	if (argc > MAX_INTERFACES) {
		fprintf(stderr, "Exceeded maximum number of supported interfaces of %d\n", MAX_INTERFACES);
		return 1;
	}
	
	num_interfaces = 0;
	for (i = 1; i < argc; i++) {
		ifindex[num_interfaces] = if_nametoindex(argv[i]);
		if (!ifindex[num_interfaces]) {
			fprintf(stderr, "Interface %s not found!\n", argv[i]);
		}
		num_interfaces++;
	}

	for (i = 0; i < num_interfaces; i++) {
		sockets[i] = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
		if (sockets[i] < 0) {
			fprintf(stderr, "Could not create socket for ifindex %d\n", ifindex[i]);
			return 1;
		}

		if (bind_socket_to_device(sockets[i], ifindex[i])) {
			fprintf(stderr, "Error binding socket to Interface %d\n", ifindex[i]);
			return 1;
		}
	}

	/* Start receiving */
	while (1) {
		/* Check if timeout is exceeded */
		current_time = time(NULL);
		if (current_time - start_time > REMOTE_SETUP_MODE_RX_TIMEOUT) {
			break;
		}

		for (i = 0; i < num_interfaces; i++) {
			received = recv(sockets[i], recvbuf, BUFSIZE, MSG_DONTWAIT);
			if (received < 0 && errno != EAGAIN && errno != EAGAIN) {
				fprintf(stderr, "Error receiving from ifindex %d - ret %d\n", ifindex[i], errno);
				continue;
			}
			if (received <= 0) {
				continue;
			}

			if (!should_reset(recvbuf, received)) {
				continue;
			}

			return 0;
		}
	}

	return 1;
}
