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

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

void usage() {
  puts("Usage: gluon-announced [-h] -m <group> -p <port> -i <if0> [-i <if1> ..] -s <script>");
  puts("  -m <ip6>         multicast group, e.g. ff02:0:0:0:0:0:2:1001");
  puts("  -p <int>         port number to listen on");
  puts("  -i <string>      interface on which the group is joined");
  puts("  -s <string>      script to be executed for each request");
  puts("  -h               this help\n");
}

/* The maximum size of output returned is limited to 8192 bytes (including
 * terminating null byte) for now. If this turns out to be problem, a
 * dynamic buffer should be implemented instead of increasing the
 * limit.
 */
#define BUFFER 8192

char *run_script(size_t *length, const char *script) {
  FILE *f;

  f = popen(script, "r");

  char *buffer;

  buffer = calloc(BUFFER, sizeof(char));

  if (buffer == NULL) {
    fprintf(stderr, "couldn't allocate buffer\n");
    return NULL;
  }


  size_t read_bytes = 0;
  while (1) {
    ssize_t ret = fread(buffer+read_bytes, sizeof(char), BUFFER-read_bytes, f);

    if (ret <= 0)
      break;

    read_bytes += ret;
  }

  if (fclose(f) != 0)
    fprintf(stderr, "fclose on script failed\n");

  *length = read_bytes;

  return buffer;
}

void join_mcast(const int sock, const struct in6_addr addr, const char *iface) {
  struct ipv6_mreq mreq;

  mreq.ipv6mr_multiaddr = addr;
  mreq.ipv6mr_interface = if_nametoindex(iface);

  if (mreq.ipv6mr_interface == 0)
    goto error;

  if (setsockopt(sock, IPPROTO_IPV6, IPV6_JOIN_GROUP, &mreq, sizeof(mreq)) == -1)
    goto error;

  return;

error:
  fprintf(stderr, "Could not join multicast group on %s: ", iface);
  perror(NULL);
  return;
}

#define REQUESTSIZE 64

char *recvrequest(const int sock, struct sockaddr *client_addr, socklen_t *clilen) {
  char request_buffer[REQUESTSIZE];
  ssize_t read_bytes;

  read_bytes = recvfrom(sock, request_buffer, sizeof(request_buffer), 0, client_addr, clilen);

  if (read_bytes < 0) {
    perror("recvfrom failed");
    exit(EXIT_FAILURE);
  }

  char *request = strndup(request_buffer, read_bytes);

  if (request == NULL)
    perror("Could not receive request");

  return strsep(&request, "\r\n\t ");
}

void serve(const int sock, const char *script) {
  char *request;
  socklen_t clilen;
  struct sockaddr_in6 client_addr;

  clilen = sizeof(client_addr);

  while (1) {
    request = recvrequest(sock, (struct sockaddr*)&client_addr, &clilen);

    int cmp = strcmp(request, "nodeinfo");
    free(request);

    if (cmp != 0)
      continue;

    char *msg;
    size_t msg_length;
    msg = run_script(&msg_length, script);

    if (sendto(sock, msg, msg_length, 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) < 0) {
      perror("sendto failed");
      exit(EXIT_FAILURE);
    }

    free(msg);
  }
}

int main(int argc, char **argv) {
  int sock;
  struct sockaddr_in6 server_addr = {};
  char *script = NULL;
  struct in6_addr mgroup_addr;

  sock = socket(PF_INET6, SOCK_DGRAM, 0);

  if (sock < 0) {
    perror("creating socket");
    exit(EXIT_FAILURE);
  }

  server_addr.sin6_family = AF_INET6;
  server_addr.sin6_addr = in6addr_any;

  opterr = 0;

  int group_set = 0;

  int c;
  while ((c = getopt(argc, argv, "p:g:s:i:h")) != -1)
    switch (c) {
      case 'p':
        server_addr.sin6_port = htons(atoi(optarg));
        break;
      case 'g':
        if (!inet_pton(AF_INET6, optarg, &mgroup_addr)) {
          perror("Invalid multicast group. This message will probably confuse you");
          exit(EXIT_FAILURE);
        }

        group_set = 1;
        break;
      case 's':
        free(script); // in case -s is given multiple times

        script = strdup(optarg);

        if (script == NULL) {
          perror("Couldn't duplicate string");
          exit(EXIT_FAILURE);
        }
        break;
      case 'i':
        if (!group_set) {
          fprintf(stderr, "Multicast group must be given before interface.\n");
          exit(EXIT_FAILURE);
        }
        join_mcast(sock, mgroup_addr, optarg);
        break;
      case 'h':
        usage();
        exit(EXIT_SUCCESS);
        break;
      default:
        fprintf(stderr, "Invalid parameter %c ignored.\n", c);
    }

  if (script == NULL) {
    fprintf(stderr, "No script given\n");
    exit(EXIT_FAILURE);
  }

  if (bind(sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
    perror("bind failed");
    exit(EXIT_FAILURE);
  }

  serve(sock, script);

  free(script);

  return EXIT_FAILURE;
}
