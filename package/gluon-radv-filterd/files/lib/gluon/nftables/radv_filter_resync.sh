#!/bin/sh

# Restart the daemon after fw4 recreates its nftables chain.

if /etc/init.d/gluon-radv-filterd enabled 2>/dev/null && \
	/etc/init.d/gluon-radv-filterd running 2>/dev/null; then
	/etc/init.d/gluon-radv-filterd restart >/dev/null 2>&1
fi
