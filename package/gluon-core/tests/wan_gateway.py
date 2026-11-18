#!/usr/bin/env python3
"""A node with an uplink reaches the internet on every address family
its uplink can source traffic from. A family without a usable source
address (QEMU's user networking hands out fec0::/64) is reported and
skipped. Targets: GLUON_TEST_V4_TARGET, GLUON_TEST_V6_TARGET.
"""
from pynet import Node, start, finish
from meshlib import (
    V4_TARGET, V6_TARGET, wait_uplink, uplink_routable, reaches_internet)

FAMILIES = ((4, V4_TARGET), (6, V6_TARGET))

a = Node()

start()

failures = []
for family, target in FAMILIES:
    wait_uplink(a, family)
    if not uplink_routable(a, family):
        a.dbg(
            'uplink has no usable IPv{} source address, only checking'
            ' that the uplink itself is up'.format(family))
        continue
    if not reaches_internet(a, family, target):
        failures.append('no IPv{} connectivity to {}'.format(family, target))

if failures:
    raise AssertionError('; '.join(failures))

finish()
