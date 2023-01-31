/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * Utility for entering Setup_mode using network
 *
 * Copyright (c) David Bauer <mail@david-bauer.net>
 */

#define _GNU_SOURCE

#include <arpa/inet.h>
#include <errno.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <poll.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

#include "gluon-remote-setup-mode.h"

#define MAX_INTERFACES	64
#define BUFSIZE		1024


static const uint8_t destination[] = { REMOTE_SETUP_MODE_DST_MAC };
static const uint8_t type[] = { REMOTE_SETUP_MODE_ETHERTYPE };
/* Command including its terminating NUL byte */
static const char command[] = REMOTE_SETUP_MODE_DATA_CMD_SETUP;


static int open_socket(const char *ifname)
{
	struct sockaddr_ll sll = {
		.sll_family = AF_PACKET,
		/* Only receive frames with our ethertype */
		.sll_protocol = htons(type[0] << 8 | type[1]),
	};
	struct packet_mreq mreq = {
		.mr_type = PACKET_MR_MULTICAST,
		.mr_alen = sizeof(destination),
	};
	int fd;

	memcpy(mreq.mr_address, destination, sizeof(destination));

	/* if_nametoindex() returns 0 on error. Binding to ifindex 0 would
	 * receive from all interfaces, so this must be treated as fatal. */
	sll.sll_ifindex = if_nametoindex(ifname);
	if (!sll.sll_ifindex) {
		fprintf(stderr, "Interface %s not found\n", ifname);
		return -1;
	}

	/* Create the socket without protocol, so it does not receive any frames
	 * before it is bound to the interface */
	fd = socket(AF_PACKET, SOCK_RAW, 0);
	if (fd < 0) {
		fprintf(stderr, "Could not create socket for %s: %m\n", ifname);
		return -1;
	}

	if (bind(fd, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
		fprintf(stderr, "Error binding socket to %s: %m\n", ifname);
		close(fd);
		return -1;
	}

	/* Receive frames sent to the destination address even if the NIC
	 * filters multicast. The membership ends when the socket is closed.
	 * Many NICs do not filter, so keep listening if this fails. */
	mreq.mr_ifindex = sll.sll_ifindex;
	if (setsockopt(fd, SOL_PACKET, PACKET_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0)
		fprintf(stderr, "Warning: could not join multicast group on %s: %m\n", ifname);

	return fd;
}

static int is_setup_request(const uint8_t *buf, size_t size)
{
	/* Frames shorter than the minimum Ethernet frame size are padded by the
	 * sender, so only check the fixed part of the frame and ignore the rest */
	if (size < REMOTE_SETUP_MODE_DATA_CMD_OFFSET + sizeof(command))
		return 0;

	if (memcmp(destination, &buf[REMOTE_SETUP_MODE_DST_MAC_OFFSET], sizeof(destination)))
		return 0;

	if (memcmp(type, &buf[REMOTE_SETUP_MODE_ETHERTYPE_OFFSET], sizeof(type)))
		return 0;

	if (memcmp(command, &buf[REMOTE_SETUP_MODE_DATA_CMD_OFFSET], sizeof(command)))
		return 0;

	return 1;
}

static long remaining_ms(const struct timespec *deadline)
{
	struct timespec now;

	clock_gettime(CLOCK_MONOTONIC, &now);

	return (deadline->tv_sec - now.tv_sec) * 1000 +
		(deadline->tv_nsec - now.tv_nsec) / 1000000;
}

int main(int argc, char *argv[])
{
	struct pollfd fds[MAX_INTERFACES];
	uint8_t recvbuf[BUFSIZE];
	struct timespec deadline;
	int num_interfaces;
	int num_open = 0;
	ssize_t received;
	long timeout;
	int i;

	if (argc < 2) {
		fprintf(stderr, "At least one interface name is required\n");
		return 1;
	}

	num_interfaces = argc - 1;
	if (num_interfaces > MAX_INTERFACES) {
		fprintf(stderr, "Exceeded maximum number of supported interfaces of %d\n", MAX_INTERFACES);
		return 1;
	}

	/* Listen on the interfaces that could be opened; poll() ignores the
	 * negative file descriptors of the others */
	for (i = 0; i < num_interfaces; i++) {
		fds[i].fd = open_socket(argv[i + 1]);
		fds[i].events = POLLIN;
		if (fds[i].fd >= 0)
			num_open++;
	}

	if (!num_open)
		return 1;

	clock_gettime(CLOCK_MONOTONIC, &deadline);
	deadline.tv_sec += REMOTE_SETUP_MODE_RX_TIMEOUT;

	while ((timeout = remaining_ms(&deadline)) > 0) {
		if (poll(fds, num_interfaces, timeout) < 0) {
			if (errno == EINTR)
				continue;

			fprintf(stderr, "poll: %m\n");
			return 1;
		}

		for (i = 0; i < num_interfaces; i++) {
			if (fds[i].revents & POLLERR) {
				/* Reading the pending error clears it, so the socket
				 * can be polled again */
				int err;
				socklen_t len = sizeof(err);
				getsockopt(fds[i].fd, SOL_SOCKET, SO_ERROR, &err, &len);
			}

			if (fds[i].revents & (POLLHUP | POLLNVAL)) {
				/* Stop polling this socket instead of spinning on it */
				fds[i].fd = -1;
				continue;
			}

			if (!(fds[i].revents & POLLIN))
				continue;

			received = recv(fds[i].fd, recvbuf, sizeof(recvbuf), MSG_DONTWAIT);
			if (received < 0)
				continue;

			if (is_setup_request(recvbuf, received))
				return 0;
		}
	}

	return 1;
}
