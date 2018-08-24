local uci = require('simple-uci').cursor()
local unistd = require 'posix.unistd'

local M = {}

function M.get_mesh_vpn_interface()
  local ret = {}
  if unistd.access('/lib/gluon/mesh-vpn/fastd') then
    local vpnifac = uci:get('fastd', 'mesh_vpn_backbone', 'net')
    if vpnifac  ~= nil then
      vpnifac = vpnifac:gsub("%_",'-')
      table.insert(ret,vpnifac)
    end
  end
  if unistd.access('/lib/gluon/mesh-vpn/tunneldigger') then
    local vpnifac = uci:get('tunneldigger', 'mesh_vpn', 'interface')
    if vpnifac  ~= nil then
      table.insert(ret,vpnifac)
    end
  end
  return ret
end

return M
