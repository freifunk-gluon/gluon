bridge_rule('MULTICAST_OUT', 'ip protocol 89 return comment "OSPF"')
bridge_rule('MULTICAST_OUT', 'ether type ip6 meta l4proto 89 return comment "OSPF"')
