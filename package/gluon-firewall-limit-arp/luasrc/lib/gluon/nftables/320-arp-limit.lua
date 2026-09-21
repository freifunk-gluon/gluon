bridge_include_table('pre', 'arp_limit')

bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" arp operation request jump arp_limit')

-- Every firewall reload rebuilds the table above, emptying the sets the
-- arp limiter maintains; it has to be told to start over.
include('arp_limit_resync', {
	type = 'script',
	path = '/lib/gluon/nftables/arp_limit_resync.sh',
	fw4_compatible = '1',
})
