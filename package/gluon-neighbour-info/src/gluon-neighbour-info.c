/*
   Copyright (c) 2014, Nils Schneider <nils@nilsschneider.net>
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   */

#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <time.h>

void usage() {
  puts("Usage: gluon-neighbour-info [-h] [-s] [-l] [-c <count>] [-t <sec>] -d <dest> -p <port> -i <if0> -r <request>");
  puts("  -p <int>         UDP port");
  puts("  -d <ip6>         destination address (unicast ip6 or multicast group, e.g. ff02:0:0:0:0:0:2:1001)");
  puts("  -i <string>      interface, e.g. eth0 ");
  puts("  -r <string>      request, e.g. nodeinfo");
  puts("  -t <sec>         timeout in seconds (default: 3)");
  puts("  -s <event>       output as server-sent events of type <event>");
  puts("                   or without type if <event> is the empty string");
  puts("  -c <count>       only wait for at most <count> replies");
  puts("  -l               after timeout (or <count> replies if -c is given),");
  puts("                   send another request and loop forever");
  puts("  -h               this help\n");
}

void getclock(struct timeval *tv) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  tv->tv_sec = ts.tv_sec;
  tv->tv_usec = ts.tv_nsec / 1000;
}

/* Assumes a and b are normalized */
void tv_subtract (struct timeval *r, const struct timeval *a, const struct timeval *b) {
  r->tv_usec = a->tv_usec - b->tv_usec;
  r->tv_sec = a->tv_sec - b->tv_sec;

  if (r->tv_usec < 0) {
    r->tv_usec += 1000000;
    r->tv_sec -= 1;
  }
}

ssize_t recvtimeout(int socket, void *buffer, size_t length, int flags, const struct timeval *timeout) {
  struct timeval now, timeout_left;

  getclock(&now);
  tv_subtract(&timeout_left, timeout, &now);

  if (timeout_left.tv_sec < 0)
    return -1;

  setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &timeout_left, sizeof(timeout_left));
  return recv(socket, buffer, length, flags);
}

int request(const int sock, const struct sockaddr_in6 *client_addr, const char *request, const char *sse, double timeout, unsigned int max_count) {
  ssize_t ret;
  char buffer[8192];
  unsigned int count = 0;

  ret = sendto(sock, request, strlen(request), 0, (struct sockaddr *)client_addr, sizeof(struct sockaddr_in6));

  if (ret < 0) {
    perror("Error in sendto()");
    exit(EXIT_FAILURE);
  }

  struct timeval tv_timeout;
  getclock(&tv_timeout);

  tv_timeout.tv_sec += (int) timeout;
  tv_timeout.tv_usec += ((int) (timeout * 1000000)) % 1000000;
  if (tv_timeout.tv_usec >= 1000000) {
    tv_timeout.tv_usec -= 1000000;
    tv_timeout.tv_sec += 1;
  }

  do {
    ret = recvtimeout(sock, buffer, sizeof(buffer), 0, &tv_timeout);

    if (ret < 0)
      break;

    if (sse) {
      if (sse[0] != '\0')
        fprintf(stdout, "event: %s\n", sse);
      fputs("data: ", stdout);
    }

    fwrite(buffer, sizeof(char), ret, stdout);

    if (sse)
      fputs("\n\n", stdout);
    else
      fputs("\n", stdout);

    fflush(stdout);
    count++;
  } while (max_count == 0 || count < max_count);

  if ((max_count == 0 && count == 0) || count < max_count)
    return EXIT_FAILURE;
  else
    return EXIT_SUCCESS;
}

int main(int argc, char **argv) {
  int sock;
  struct sockaddr_in6 client_addr = {};
  char *request_string = NULL;

  sock = socket(PF_INET6, SOCK_DGRAM, 0);

  if (sock < 0) {
    perror("creating socket");
    exit(EXIT_FAILURE);
  }

  client_addr.sin6_family = AF_INET6;

  opterr = 0;

  int max_count = 0;
  double timeout = 3.0;
  char *sse = NULL;
  bool loop = false;
  int ret = false;

  int c;
  while ((c = getopt(argc, argv, "p:d:r:i:t:s:c:lh")) != -1)
    switch (c) {
      case 'p':
        client_addr.sin6_port = htons(atoi(optarg));
        break;
      case 'd':
        if (!inet_pton(AF_INET6, optarg, &client_addr.sin6_addr)) {
          perror("Invalid IPv6 address. This message will probably confuse you");
          exit(EXIT_FAILURE);
        }
        break;
      case 'i':
        client_addr.sin6_scope_id = if_nametoindex(optarg);
        if (client_addr.sin6_scope_id == 0) {
          perror("Can not use interface");
          exit(EXIT_FAILURE);
        }
        break;
      case 'r':
        request_string = optarg;
        break;
      case 't':
        timeout = atof(optarg);
        if (timeout < 0) {
          perror("Negative timeout not supported");
          exit(EXIT_FAILURE);
        }
        break;
      case 's':
        sse = optarg;
        break;
      case 'l':
        loop = true;
        break;
      case 'c':
        max_count = atoi(optarg);
        if (max_count < 0) {
          perror("Negative count not supported");
          exit(EXIT_FAILURE);
        }
        break;
      case 'h':
        usage();
        exit(EXIT_SUCCESS);
        break;
      default:
        fprintf(stderr, "Invalid parameter %c ignored.\n", c);
    }

  if (request_string == NULL) {
    fprintf(stderr, "No request string supplied\n");
    exit(EXIT_FAILURE);
  }

  if (client_addr.sin6_port == htons(0)) {
	fprintf(stderr, "No port supplied\n");
	exit(EXIT_FAILURE);
  }

  if (IN6_IS_ADDR_UNSPECIFIED(&client_addr.sin6_addr)) {
	fprintf(stderr, "No destination address supplied\n");
	exit(EXIT_FAILURE);
  }

  if (sse) {
    fputs("Content-Type: text/event-stream\n\n", stdout);
    fflush(stdout);
  }

  do {
    ret = request(sock, &client_addr, request_string, sse, timeout, max_count);
  } while(loop);

  if (sse)
    fputs("event: eot\ndata: null\n\n", stdout);

  return ret;
}
