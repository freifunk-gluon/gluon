# SPDX-FileCopyrightText: 2017 Linus Lüssing <linus.luessing@c0d3.blue>
# SPDX-License-Identifier: GPL-2.0-or-later

all: gluon-arp-limiter

CFLAGS += -Wall

gluon-arp-limiter: gluon-arp-limiter.c addr_store.c lookup3.c mac.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -fPIC -D_GNU_SOURCE -o $@ $^ $(LDLIBS)

clean:
	rm -f gluon-arp-limiter
