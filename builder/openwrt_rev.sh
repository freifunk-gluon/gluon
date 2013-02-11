#!/bin/sh

echo "r$(git --git-dir="$1"/.git/modules/openwrt log | grep -m 1 git-svn-id | awk '{ gsub(/.*@/, "", $0); print $1 }')"
