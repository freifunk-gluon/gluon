bridge_chain('IN_ONLY')
bridge_chain('OUT_ONLY')

-- MULTICAST_IN is jumped to from the prerouting chain, which runs at
-- dstnat priority (like the ebtables nat table), so IGMP/MLD can be
-- dropped before the bridge multicast snooping processes it
bridge_chain('MULTICAST_IN')
bridge_chain('MULTICAST_IN_ICMPV6')

bridge_chain('MULTICAST_OUT')
bridge_chain('MULTICAST_OUT_ICMPV6')
