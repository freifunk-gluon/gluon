#!/bin/sh

export GLUONDIR="$(dirname "$0")/.."

"$GLUONDIR"/openwrt/staging_dir/host/bin/lua -e "dofile(os.getenv('GLUONDIR') .. '/scripts/load_site.lua') print(assert(config.$1))" 2>/dev/null
