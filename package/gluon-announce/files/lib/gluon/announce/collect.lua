#!/usr/bin/lua

local announce = require 'gluon.announce'
local json = require 'luci.json'
local ltn12 = require 'luci.ltn12'

local announce_dir = '/lib/gluon/announce/' .. arg[1] .. '.d'

encoder = json.Encoder(announce.collect_dir(announce_dir))
ltn12.pump.all(encoder:source(), ltn12.sink.file(io.stdout))
