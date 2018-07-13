#!/usr/bin/lua

local RESOLV_CONF = '/var/gluon/wan-dnsmasq/resolv.conf'


local stat = require 'posix.sys.stat'
local ubus = require('ubus').connect()
local uci = require('simple-uci').cursor()
local util = require 'gluon.util'


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


local old_servers = util.readfile(RESOLV_CONF)

if new_servers ~= old_servers then
  stat.mkdir('/var/gluon')
  stat.mkdir('/var/gluon/wan-dnsmasq')

  local f = io.open(RESOLV_CONF .. '.tmp', 'w')
  f:write(new_servers)
  f:close()

  os.rename(RESOLV_CONF .. '.tmp', RESOLV_CONF)
end
