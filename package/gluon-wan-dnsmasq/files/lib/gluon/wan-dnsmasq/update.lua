#!/usr/bin/lua

local RESOLV_CONF_DIR = '/var/gluon/wan-dnsmasq'
local RESOLV_CONF = RESOLV_CONF_DIR .. '/resolv.conf'


local ubus = require('ubus').connect()
local uci = require('luci.model.uci').cursor()
local fs = require 'nixio.fs'


local function write_servers(f, servers)
  for _, server in ipairs(servers) do
    f:write('nameserver ', server, '\n')
  end
end

local function write_interface_servers(f, iface)
  write_servers(f, ubus:call('network.interface.' .. iface, 'status', {}).inactive['dns-server'])
end


fs.mkdirr(RESOLV_CONF_DIR)
local f = io.open(RESOLV_CONF, 'w+')

local static = uci:get_first('gluon-wan-dnsmasq', 'static', 'server')

if type(static) == 'table' and #static > 0 then
  write_servers(f, static)
else
  pcall(write_interface_servers, f, 'wan6')
  pcall(write_interface_servers, f, 'wan')
end

f:close()
