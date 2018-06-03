#!/bin/sh

export GLUON_SITE_CONFIG=site.conf
exec openwrt/staging_dir/hostpkg/bin/lua -e "print(assert(dofile('scripts/site_config.lua').$1))" 2>/dev/null
