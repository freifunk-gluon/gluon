module("luci.controller.admin.mesh_vpn_fastd", package.seeall)

function index()
  entry({"admin", "mesh_vpn_fastd"}, cbi("admin/mesh_vpn_fastd"), _("Mesh VPN"), 20)
end
