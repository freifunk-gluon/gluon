#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <netinet/in.h>
#include <netinet/ip6.h>
#include <netinet/icmp6.h>

#include <linux/netfilter.h>

#include <libnfnetlink/libnfnetlink.h>
#include <libnetfilter_queue/libnetfilter_queue.h>

#define QUEUE_NUMBER 0
#define HWADDR_SIZE 6
#define BUFSIZE 1500
#define BATADV_GW_FILE "/sys/kernel/debug/batman_adv/bat0/gateways"
#define BATADV_REFRESH_INTERVAL 60

#ifdef DEBUG
#define ASSERT(stmt) \
    if(!(stmt)) { \
        fprintf(stderr, "Assertion failed: " #stmt "\n"); \
        goto fail; \
    }
#else
#define ASSERT(stmt) if(!(stmt)) goto fail;
#endif

struct ip6_pseudo_hdr {
    struct in6_addr src;
    struct in6_addr dst;
    uint32_t plen;
    uint8_t pad[3];
    uint8_t nxt;
};

// cf. RFC 1071 section 4.1
uint16_t checksum(void *buf, int count, uint16_t start) {
    register uint32_t sum = start;
    uint16_t *addr = buf;

    while (count > 1) {
        sum += *addr++;
        count -= 2;
    }

    if (count > 0)
        sum += htons(*(uint8_t *)addr);

    while (sum >> 16)
        sum = (sum & 0xffff) + (sum >> 16);

    return ~sum;
}

bool is_chosen_gateway(uint8_t *hw_addr) {
    static uint8_t gateway[HWADDR_SIZE];
    static time_t t;

    if (time(NULL) - t >= BATADV_REFRESH_INTERVAL) {
        FILE *f = fopen(BATADV_GW_FILE, "r");
        if (!f)
            return false;

        char *line = NULL;
        size_t len = 0;

        while (getline(&line, &len, f) >= 0) {
            if (HWADDR_SIZE == sscanf(line, "=> %hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
                    &gateway[0],
                    &gateway[1],
                    &gateway[2],
                    &gateway[3],
                    &gateway[4],
                    &gateway[5])) {
                t = time(NULL);
                break;
            }
        }
        free(line);
        fclose(f);
    }

    return memcmp(gateway, hw_addr, HWADDR_SIZE) == 0;
}

int process_packet(struct nfq_q_handle *qh, struct nfgenmsg *nfmsg, struct nfq_data *nfad, void *data) {
    int len;
    struct nfqnl_msg_packet_hdr *pkt_hdr;
    struct ip6_pseudo_hdr phdr = {};
    struct ip6_hdr *pkt;
    struct ip6_ext *ext;
    struct nd_router_advert *ra;
    struct nfqnl_msg_packet_hw *source;
    uint8_t ext_type;
    uint16_t hdrchksum;

    pkt_hdr = nfq_get_msg_packet_hdr(nfad);

    source = nfq_get_packet_hw(nfad);
    ASSERT(is_chosen_gateway(source->hw_addr));

    len = nfq_get_payload(nfad, (unsigned char**)&pkt);
    ASSERT(len > sizeof(struct ip6_hdr));
    ASSERT(len >= ntohs(pkt->ip6_plen) + sizeof(struct ip6_hdr));

    ext_type = pkt->ip6_nxt;
    ext = (void*)pkt + sizeof(struct ip6_hdr);
    while (ext_type != IPPROTO_ICMPV6) {
        ASSERT((void*)ext < (void*)pkt + sizeof(struct ip6_hdr) + len);
        ext_type = ext->ip6e_nxt;
        ext = (void*)ext + ext->ip6e_len;
    }
    ra = (struct nd_router_advert*)ext;
    ASSERT(len >= (void*)ra - (void*)pkt + sizeof(struct nd_router_advert));
    ASSERT(ra->nd_ra_type == ND_ROUTER_ADVERT);
    ASSERT(ra->nd_ra_code == 0);
    ASSERT((ra->nd_ra_flags_reserved & (0x03 << 3)) == 0x00);

    phdr.nxt = IPPROTO_ICMPV6;
    // original plen - length of IPv6 extension headers
    phdr.plen = htonl(ntohs(pkt->ip6_plen) - ((void*)ra - (void*)pkt - sizeof(struct ip6_hdr)));
    memcpy(&phdr.src, &pkt->ip6_src, sizeof(struct in6_addr));
    memcpy(&phdr.dst, &pkt->ip6_dst, sizeof(struct in6_addr));
    hdrchksum = ~checksum(&phdr, sizeof(struct ip6_pseudo_hdr), 0);

    ASSERT(checksum(ra, phdr.plen, hdrchksum) == 0);

    // Validation complete, set preference to high
    ra->nd_ra_flags_reserved |= (0x01 << 3);

    ra->nd_ra_cksum = 0;
    ra->nd_ra_cksum = htons(checksum(ra, phdr.plen, hdrchksum));

#ifdef DEBUG
    printf("pkt modified\n");
#endif

    nfq_set_verdict(qh, pkt_hdr->packet_id, NF_ACCEPT, len, (unsigned char*) pkt);
    return 0;

    fail:
    // accept packet in any case, but don't copy data around
    nfq_set_verdict(qh, pkt_hdr->packet_id, NF_ACCEPT, 0, NULL);
    return 1;
}

int main(int argc, char* argv[]) {
    int fd, rv, ret = 0;
    char buf[BUFSIZE];
    struct nfq_q_handle *qh;
    struct nfq_handle *h;

    h = nfq_open();
    if (!h) {
        perror("nfq_open()");
        goto fail;
    }

    if (nfq_unbind_pf(h, AF_INET6) < 0 ) {
        perror("nfq_unbind_pf()");
        fprintf(stderr, "Probably we are missing CAP_NET_ADMIN\n");
        goto fail;
    }

    if (nfq_bind_pf(h, AF_INET6) < 0) {
        perror("nfq_bind_pf()");
        goto fail;
    }

    qh = nfq_create_queue(h, QUEUE_NUMBER, &process_packet, NULL);
    if (!qh) {
        perror("nfq_create_queue()\n");
        goto fail;
    }

    if (nfq_set_mode(qh, NFQNL_COPY_PACKET, BUFSIZE) < 0) {
        perror("nfq_set_mode()\n");
        goto fail;
    }

    fd = nfq_fd(h);
    while ((rv = recv(fd, buf, sizeof(buf), 0)) >= 0) {
#ifdef DEBUG
        printf("pkt received\n");
#endif
        nfq_handle_packet(h, buf, rv);
    }

    goto cleanup;
    fail:
    ret = 1;
    cleanup:
    nfq_close(h);
    return ret;
}
