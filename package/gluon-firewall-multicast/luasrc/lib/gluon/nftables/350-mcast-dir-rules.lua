-- The ether daddr mask matches all multicast (including broadcast)
-- destinations, like the ebtables 'Multicast' alias did

bridge_rule('PREROUTING',
	'ether daddr & 01:00:00:00:00:00 == 01:00:00:00:00:00 ibrname "br-client" iifname "bat0" jump multicast_in')
bridge_rule('OUTPUT',
	'ether daddr & 01:00:00:00:00:00 == 01:00:00:00:00:00 obrname "br-client" oifname "bat0" jump multicast_out')
bridge_rule('FORWARD',
	'ether daddr & 01:00:00:00:00:00 == 01:00:00:00:00:00 obrname "br-client" oifname "bat0" jump multicast_out')

bridge_rule('MULTICAST_IN', 'ether type ip6 meta l4proto ipv6-icmp jump multicast_in_icmpv6')
bridge_rule('MULTICAST_OUT', 'ether type ip6 meta l4proto ipv6-icmp jump multicast_out_icmpv6')
