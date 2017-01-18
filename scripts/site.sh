#!/bin/sh

exec lede/staging_dir/hostpkg/bin/lua -e "print(assert(dofile('scripts/site_config.lua').$1))" 2>/dev/null
