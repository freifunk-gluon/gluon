#!/usr/bin/lua

local RESOLV_CONF_DIR = '/var/gluon/wan-dnsmasq'
local RESOLV_CONF = RESOLV_CONF_DIR .. '/resolv.conf'


local ubus = require('ubus').connect()
local uci = require('luci.model.uci').cursor()
local fs = require 'nixio.fs'


local new_servers = ''


local function append_servers(servers)
  for _, server in ipairs(servers) do
    new_servers = new_servers .. 'nameserver ' .. server .. '\n'
  end
end

local function append_interface_servers(iface)
  append_servers(ubus:call('network.interface.' .. iface, 'status', {}).inactive['dns-server'])
end


local static = uci:get_first('gluon-wan-dnsmasq', 'static', 'server')

if type(static) == 'table' and #static > 0 then
  append_servers(static)
else
  pcall(append_interface_servers, 'wan6')
  pcall(append_interface_servers, 'wan')
end


fs.mkdirr(RESOLV_CONF_DIR)

local old_servers = fs.readfile(RESOLV_CONF)

if new_servers ~= old_servers then
   local f = io.open(RESOLV_CONF .. '.tmp', 'w')
   f:write(new_servers)
   f:close()

   fs.rename(RESOLV_CONF .. '.tmp', RESOLV_CONF)
end
