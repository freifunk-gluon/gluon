-- These early returns only matter for zero-source replies dropped below;
-- requiring a zero target preserves the old --arp-gratuitous check.
bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip 0.0.0.0 arp daddr ip 0.0.0.0 arp daddr ether & ff:ff:ff:fc:00:00 == ff:43:05:00:00:00 return')
bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip 0.0.0.0 arp daddr ip 0.0.0.0 arp daddr ether & ff:ff:ff:ff:00:00 == ff:43:05:05:00:00 return')

bridge_rule('MULTICAST_OUT', 'arp operation reply arp saddr ip 0.0.0.0 counter drop')
bridge_rule('MULTICAST_OUT', 'arp operation request arp daddr ip 0.0.0.0 counter drop')
bridge_rule('MULTICAST_OUT', 'ether type arp return')
