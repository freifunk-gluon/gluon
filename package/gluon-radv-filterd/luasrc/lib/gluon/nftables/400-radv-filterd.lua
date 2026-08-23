bridge_chain('RADV_FILTER')

bridge_rule('FORWARD', 'iifname "bat0" icmpv6 type nd-router-advert jump radv_filter')

-- Accept everything until the daemon has chosen a router; the daemon
-- replaces the chain content with 'ether saddr != <router> counter drop'
bridge_rule('RADV_FILTER', 'accept')

include('radv_filter_resync', {
	type = 'script',
	path = '/lib/gluon/nftables/radv_filter_resync.sh',
	fw4_compatible = '1',
})
