-- High-level network config functions

local mesh = require 'gluon.mesh'
local uci = require('luci.model.uci').cursor()

module 'gluon.network'

function update_mesh_on_wan()
  if uci:get_bool('network', 'mesh_wan', 'auto') then
    mesh.register_interface('br-wan', {transitive = true, fixed_mtu = true})
  else
    mesh.unregister_interface('br-wan')
  end
end
