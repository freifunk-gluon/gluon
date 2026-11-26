#!/usr/bin/env python3
# requires: gluon-mesh-batman-adv
"""respondd answers the link-local group on a mesh device, and its
batadv facts name the querying node's direct neighbours.

The mesh interface is whatever the site's interface roles produced, so
it is looked up rather than named."""
import json

from pynet import start, finish
from meshlib import pair, wait_connected

a, b = pair()

start()

wait_connected(b, a)


def mesh_iface(node):
    return node.succeed('gluon-list-mesh-interfaces').split()[0]


dev_a, dev_b = mesh_iface(a), mesh_iface(b)
mac_a = a.succeed('cat /sys/class/net/{}/address'.format(dev_a)).strip()
mac_b = b.succeed('cat /sys/class/net/{}/address'.format(dev_b)).strip()

replies = [json.loads(line) for line in b.wait_until_succeeds(
    'gluon-neighbour-info -d ff02::2:1001 -p 1001 -r neighbours'
    ' -i {} -c 2'.format(dev_b)).split('\n')]
b.dbg('neighbours:\n' + json.dumps(replies, indent=4))

for reply in replies:
    neighbours = reply.get('batadv', {}).get(mac_a, {}).get('neighbours', {})
    if mac_b in neighbours:
        break
else:
    raise AssertionError(
        '{} is not among the batadv neighbours node1 reports on {}'
        .format(mac_b, mac_a))

finish()
