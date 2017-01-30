#!/usr/bin/lua

local RESOLV_CONF_DIR = '/var/gluon/wan-dnsmasq'
local RESOLV_CONF = RESOLV_CONF_DIR .. '/resolv.conf'


local ubus = require('ubus').connect()
local uci = require('luci.model.uci').cursor()
local fs = require 'nixio.fs'


local new_servers = ''

local function append_server(server)
  new_servers = new_servers .. 'nameserver ' .. server .. '\n'
end


local function handle_interface(status)
  local ifname = status.device
  local servers = status.inactive['dns-server']

  for _, server in ipairs(servers) do
    if server:match('^fe80:') then
      append_server(server .. '%' .. ifname)
    else
      append_server(server)
    end
  end
end

local function append_interface_servers(iface)
  handle_interface(ubus:call('network.interface.' .. iface, 'status', {}))
end


local static = uci:get_first('gluon-wan-dnsmasq', 'static', 'server')

if type(static) == 'table' and #static > 0 then
  for _, server in ipairs(static) do
    append_server(server)
  end
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
