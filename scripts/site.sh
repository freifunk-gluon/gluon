#!/bin/sh

SITE_CONFIG_LUA=scripts/site_config.lua

exec "${STAGING_DIR}/host/bin/lua" -e "print(assert(dofile(os.getenv('TOPDIR') .. '/../${SITE_CONFIG_LUA}').$1))" 2>/dev/null
