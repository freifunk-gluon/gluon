include('mesh_vpn_clamp_mss_to_pmtu', {
	position = 'chain-prepend',
	chain = 'mangle_forward',
})
