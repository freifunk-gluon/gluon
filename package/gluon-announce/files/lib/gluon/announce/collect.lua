#!/usr/bin/lua

local announce = require 'gluon.announce'
local json = require 'luci.jsonc'

local announce_dir = '/lib/gluon/announce/' .. arg[1] .. '.d'

print(json.stringify(announce.collect_dir(announce_dir)))
