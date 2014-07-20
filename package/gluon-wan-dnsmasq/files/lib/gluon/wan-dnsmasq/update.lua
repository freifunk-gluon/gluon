#!/usr/bin/lua

local RESOLV_CONF_DIR = '/var/gluon/wan-dnsmasq'
local RESOLV_CONF = RESOLV_CONF_DIR .. '/resolv.conf'


local ubus = require('ubus').connect()
local fs = require 'nixio.fs'


local function write_servers(f, iface)
  local servers = ubus:call('network.interface.' .. iface, 'status', {}).inactive['dns-server']
  for _, server in ipairs(servers) do
    f:write('nameserver ', server, '\n')
  end
end


fs.mkdirr(RESOLV_CONF_DIR)
local f = io.open(RESOLV_CONF, 'w+')

pcall(write_servers, f, 'wan6')
pcall(write_servers, f, 'wan')

f:close()
