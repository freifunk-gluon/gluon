bridge_rule('MULTICAST_OUT_ICMPV6', 'icmpv6 type echo-request return')
bridge_rule('MULTICAST_OUT_ICMPV6', 'icmpv6 type 139 return comment "ICMP Node Information Query"')
bridge_rule('MULTICAST_OUT_ICMPV6', 'accept')
