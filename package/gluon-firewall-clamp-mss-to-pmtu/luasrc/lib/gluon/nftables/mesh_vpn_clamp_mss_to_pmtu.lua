include('mesh_vpn_clamp_mss_to_pmtu', {
	position = 'chain-append',
	chain = 'mangle_forward',
})
