#!/usr/bin/env python3
# requires: gluon-ebtables-filter-multicast gluon-ebtables-filter-ra-dhcp gluon-ebtables-limit-arp
"""Sends each kind of frame the client-bridge firewall should pass or
drop from a client and reads the mesh-facing device's transmit counter,
which moves for exactly the frames the firewall let out (ebtables-tiny
exposes no per-rule counters).

Needs root (client taps) and scapy on the host.
"""
import contextlib

from pynet import start, finish
from meshlib import (
    pair, wait_connected, attach_client, Client, send_from, mesh_dev,
    mesh_tx, flood_multicast)

# Each case is sent COPIES times; the majority decides.
COPIES = 20

PASS, DROP = 'pass', 'drop'

a, b = pair()
attach_client(a)

start()

wait_connected(a, b)
flood_multicast(a)

client = Client(a)
client.move_to(a)
client.wait_addr()

dev = mesh_dev(a)
a.dbg('watching mesh-facing device ' + dev)

results = []


def send(scapy_expr):
    """Send one case's frame from the client, COPIES times."""
    send_from(client, scapy_expr.format(n=COPIES))


@contextlib.contextmanager
def case(display, expect):
    """One kind of frame the firewall has to pass or drop; the body
    sends it and the transmit counter delta decides."""
    before = mesh_tx(a, dev)
    yield
    a.execute('sleep 2')
    forwarded = mesh_tx(a, dev) - before

    got = PASS if forwarded >= COPIES / 2 else DROP
    results.append((display, got, expect, forwarded))
    a.dbg('{:<34} mesh_tx={:<5} expected={}'.format(display, forwarded, expect))


# A client must not be able to play router or DHCP server.

with case('rogue router advertisement', DROP):
    send(
        'sendp(Ether(dst="33:33:00:00:00:01")/IPv6(dst="ff02::1")/'
        'ICMPv6ND_RA()/ICMPv6NDOptPrefixInfo('
        'prefix="2001:db8:dead::", prefixlen=64),'
        ' iface=IFACE, count={n}, verbose=0)')

with case('rogue DHCPv6 reply', DROP):
    send(
        'sendp(Ether(dst="33:33:00:01:00:02")/IPv6(dst="ff02::1:2")/'
        'UDP(sport=547, dport=546)/Raw(b"\\x07rogue"),'
        ' iface=IFACE, count={n}, verbose=0)')

with case('rogue DHCPv4 offer', DROP):
    send(
        'sendp(Ether(dst="ff:ff:ff:ff:ff:ff")/'
        'IP(src="0.0.0.0", dst="255.255.255.255")/'
        'UDP(sport=67, dport=68)/Raw(b"rogue"),'
        ' iface=IFACE, count={n}, verbose=0)')

# The all-nodes group is not carried across the mesh.

with case('all-nodes multicast', DROP):
    send(
        'sendp(Ether(dst="33:33:00:00:00:01")/IPv6(dst="ff02::1")/'
        'ICMPv6EchoRequest(id=0x4712), iface=IFACE, count={n}, verbose=0)')

# A client must still be able to ask for a router or an address, and to
# reach respondd's mesh-wide group.

with case('router solicitation', PASS):
    send(
        'sendp(Ether(dst="33:33:00:00:00:02")/IPv6(dst="ff02::2")/'
        'ICMPv6ND_RS(), iface=IFACE, count={n}, verbose=0)')

with case('DHCPv6 solicit', PASS):
    send(
        'sendp(Ether(dst="33:33:00:01:00:02")/IPv6(dst="ff02::1:2")/'
        'UDP(sport=546, dport=547)/Raw(b"\\x01solicit"),'
        ' iface=IFACE, count={n}, verbose=0)')

with case('respondd multicast', PASS):
    send(
        'sendp(Ether(dst="33:33:00:02:10:01")/IPv6(dst="ff05::2:1001")/'
        'UDP(sport=32000, dport=1001)/Raw(b"GET nodeinfo"),'
        ' iface=IFACE, count={n}, verbose=0)')

print('\n--- firewall packet matrix ---')
bad = []
for display, got, expect, forwarded in results:
    ok = got == expect
    print('{:<34} {:<9} mesh_tx={:<5} expected={}'.format(
        display, 'OK' if ok else 'MISMATCH', forwarded, expect))
    if not ok:
        bad.append(display)

if bad:
    raise AssertionError('firewall behaviour differs for: ' + ', '.join(bad))

finish()
