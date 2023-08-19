bridge_table('pre', [[set radv_allow {
	type ether_addr
}

set radv_filter {
	type ether_addr
}
]])

-- This rule starts filtering once the address is in radv_filter

-- Daemon adds 00:00:../ff:ff:.. to radv_filter (todo) so everything gets picked up,
-- effectivly turning radv_filter into a bool

bridge_rule('FORWARD', 'ether saddr @radv_filter iifname "bat0" icmpv6 type nd-router-advert ether saddr != @radv_allow drop')
