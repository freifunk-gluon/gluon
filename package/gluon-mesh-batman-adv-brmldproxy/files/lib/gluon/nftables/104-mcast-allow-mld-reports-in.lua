bridge_rule('MULTICAST_IN_ICMPV6',
	'icmpv6 type { 131, 132, 143 } return comment "MLDv1 Report, MLDv1 Done, MLDv2 Report"')
