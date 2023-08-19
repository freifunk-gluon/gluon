-- Bridge loop avoidance
-- bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip = arp daddr ip arp daddr ether ff:43:05:00:00:00/ff:ff:ff:fc:00:00 return')
-- bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip = arp daddr ip arp daddr ether ff:43:05:05:00:00/ff:ff:ff:ff:00:00 return')

bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip 0.0.0.0 drop')
bridge_rule('MULTICAST_OUT', 'arp operation request arp daddr ip 0.0.0.0 drop')
bridge_rule('MULTICAST_OUT', 'ether type arp return')
