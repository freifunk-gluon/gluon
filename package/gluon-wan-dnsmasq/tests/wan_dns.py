#!/usr/bin/env python3
# requires: gluon-mesh-vpn-core
"""gluon-wan-dnsmasq resolves over the uplink, and only the
gluon-mesh-vpn group's lookups are redirected to it; the node's own
resolver still lands on the client dnsmasq, so no resolver loop is
possible. Both halves are asserted.
"""
from pynet import Node, start, finish
from meshlib import DNS_NAME, wait_uplink, as_mesh_vpn

a = Node()

start()

wait_uplink(a, 4)

# The uplink-side resolver itself answers.
a.wait_until_succeeds('nslookup {} 127.0.0.1:54 >/dev/null'.format(DNS_NAME))

# ... and the mesh-vpn group is redirected to it.
status, out = a.execute(as_mesh_vpn('nslookup ' + DNS_NAME))
if status != 0:
    raise AssertionError(
        'mesh-vpn DNS is not redirected to gluon-wan-dnsmasq:\n' + out)

finish()
