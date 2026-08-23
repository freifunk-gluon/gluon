bridge_rule('MULTICAST_OUT', 'ip6 daddr ff02::1 counter drop')
bridge_rule('MULTICAST_OUT', 'ip6 daddr ff02::15c counter drop comment "Gluon VXLAN multicast group"')
bridge_rule('MULTICAST_OUT', 'ip6 daddr ff00::/8 meta mark set 0x4 return comment "batman-adv no-noflood mark"')
bridge_rule('MULTICAST_OUT', 'counter drop')
