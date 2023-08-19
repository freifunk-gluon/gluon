bridge_chain('IN_ONLY')
bridge_chain('OUT_ONLY')

-- nat chain runs early, so we can drop IGMP/MLD
bridge_chain('MULTICAST_IN', nil, 'nat')
bridge_chain('MULTICAST_IN_ICMPV6', nil, 'nat')

bridge_chain('MULTICAST_OUT')
bridge_chain('MULTICAST_OUT_ICMPV6')
