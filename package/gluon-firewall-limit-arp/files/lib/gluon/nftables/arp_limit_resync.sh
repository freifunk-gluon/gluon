#!/bin/sh

# Restart the limiter after fw4 recreates its nftables sets.

if /etc/init.d/gluon-arp-limiter enabled 2>/dev/null && \
	/etc/init.d/gluon-arp-limiter running 2>/dev/null; then
	/etc/init.d/gluon-arp-limiter restart >/dev/null 2>&1
fi
