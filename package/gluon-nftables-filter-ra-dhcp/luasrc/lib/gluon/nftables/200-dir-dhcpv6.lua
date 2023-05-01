bridge_rule('FORWARD', 'ip version 6 udp dport 547 jump out_only')
bridge_rule('OUTPUT', 'ip version 6 udp dport 547 jump out_only')

bridge_rule('FORWARD', 'ip version 6 udp dport 546 jump in_only')
bridge_rule('INPUT', 'ip version 6 udp dport 546 jump in_only')
