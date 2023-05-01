bridge_rule('FORWARD', 'icmpv6 type nd-router-solicit jump out_only')
bridge_rule('OUTPUT', 'icmpv6 type nd-router-solicit jump out_only')

bridge_rule('FORWARD', 'icmpv6 type nd-router-advert jump in_only')
bridge_rule('INPUT', 'icmpv6 type nd-router-advert jump in_only')
