bridge_rule('INPUT', 'iifname "bat0" icmpv6 type nd-router-solicit drop')
bridge_rule('OUTPUT', 'oifname "bat0" icmpv6 type nd-router-advert drop')
