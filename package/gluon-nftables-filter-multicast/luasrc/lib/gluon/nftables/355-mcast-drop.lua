bridge_rule('MULTICAST_OUT', 'ip6 daddr f02::1/128 drop')
bridge_rule('MULTICAST_OUT', 'ip6 daddr ff00::/8 mark 0x4 return')
bridge_rule('MULTICAST_OUT', 'drop')
