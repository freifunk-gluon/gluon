#!/bin/sh

SITE_CONFIG_LUA=scripts/site_config.lua

"$GLUONDIR"/openwrt/staging_dir/host/bin/lua -e "print(assert(dofile(os.getenv('GLUONDIR') .. '/${SITE_CONFIG_LUA}').$1))" 2>/dev/null
