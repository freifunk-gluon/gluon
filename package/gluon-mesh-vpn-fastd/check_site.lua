need_string_array 'fastd_mesh_vpn.methods'
need_number 'fastd_mesh_vpn.mtu'
need_number 'fastd_mesh_vpn.backbone.limit'


local function check_peer(k, _)
   local prefix = string.format('fastd_mesh_vpn.backbone.peers[%q].', k)

   need_string(prefix .. 'key')
   need_string_array(prefix .. 'remotes')
end

need_table('fastd_mesh_vpn.backbone.peers', check_peer)
