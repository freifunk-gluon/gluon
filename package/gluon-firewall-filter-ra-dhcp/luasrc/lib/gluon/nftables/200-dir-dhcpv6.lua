bridge_rule('FORWARD', 'ether type ip6 udp dport 547 jump out_only')
bridge_rule('OUTPUT', 'ether type ip6 udp dport 547 jump out_only')

bridge_rule('FORWARD', 'ether type ip6 udp dport 546 jump in_only')
bridge_rule('INPUT', 'ether type ip6 udp dport 546 jump in_only')
