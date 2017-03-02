# LEDE doesn't have a nice way to set the list of feeds in
# /etc/opkg/distfeeds.conf, so we use this overlay file (which is included by
# the opkg package Makefile though LEDE's IncludeOverlay mechanism).

# The following definitions make /etc/opkg/distfeeds.conf match the one included
# in official LEDE builds (by default, FEEDS_DISABLED contains the original list
# of feeds (which are unused by Gluon), and FEEDS_ENABLED our own feed list).

FEEDS_ENABLED := $(FEEDS_DISABLED)
FEEDS_DISABLED :=
