#!/usr/bin/env python3
# requires: gluon-ebtables-filter-multicast gluon-ebtables-filter-ra-dhcp gluon-ebtables-limit-arp
"""The client-bridge ebtables rules are installed, and the mesh still
works with all of them loaded."""
from pynet import start, finish
from meshlib import (
    pair, wait_connected, dump_firewall, respondd_dev, respondd_query)

a, b = pair()

start()

wait_connected(a, b)

dump = dump_firewall(a)
assert dump.strip(), 'no firewall ruleset present'

# 1. Multicast policy: all-nodes and the VXLAN group are dropped
#    towards the mesh, respondd's site-local group passes.
assert 'MULTICAST_OUT' in dump, 'no multicast egress chain in ruleset'
assert 'ff02::1' in dump, 'all-nodes multicast not filtered'
assert 'ff02::15c' in dump, 'VXLAN multicast group not filtered'
assert '1001' in dump and 'ff05::2:1001' in dump, 'respondd multicast not allowed'

# 2. Direction filters for RA/DHCP: solicitations may only leave the
#    node, advertisements/replies may only enter it.
assert 'router-solicitation' in dump, 'no RS direction rule'
assert 'router-advertisement' in dump, 'no RA direction rule'
assert '546' in dump and '547' in dump, 'no DHCPv6 direction rules'

# 3. ARP rate limiting is installed on the client bridge.
assert 'arp' in dump.lower(), 'no ARP rules'

# 4. The firewall does not break the mesh itself.
b.wait_until_succeeds('ping -c 3 node1')

# 5. respondd stays reachable across the client bridge.
b.wait_until_succeeds('[ "$({} | wc -l)" -ge 1 ]'.format(
    respondd_query(respondd_dev(b), count=2)))

finish()
