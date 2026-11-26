#!/usr/bin/env python3
"""batman-adv announces a node's clients in its translation table under
the node's originator, and a roam moves the claim.

A chain puts the far end two hops from the client, where only the
translation table can make it reachable, and the middle node holds an
announcement both before and after the roam.

Requires root (client tap and network namespace).
"""
from pynet import start, finish
from meshlib import (
    chain, wait_connected, attach_client, Client, CONVERGENCE_TIMEOUT)

TIMEOUT = CONVERGENCE_TIMEOUT['batman-adv']

a, b, c = chain(3)
attach_client(a)
attach_client(c)

start()

wait_connected(a, c)
wait_connected(c, a)


def originator(node):
    """The address the node announces its clients under."""
    return node.succeed('cat /sys/class/net/primary0/address').strip()


def wait_claimed(node, mac):
    """Wait until the node claims the client as its own."""
    node.wait_until_succeeds(
        "batctl tl | grep -qi -- '{}'".format(mac), TIMEOUT)


def wait_announced(node, mac, via):
    """Wait until the node has learned the client sits behind via."""
    node.wait_until_succeeds(
        "batctl tg | grep -i -- '{}' | grep -qi -- '{}'".format(mac, via),
        TIMEOUT)


def wait_withdrawn(node, mac, via):
    """Wait until the node no longer has the client behind via."""
    node.wait_until_succeeds(
        "! batctl tg | grep -i -- '{}' | grep -qi -- '{}'".format(mac, via),
        TIMEOUT)


orig_a, orig_c = originator(a), originator(c)
b.dbg('originators: node1={} node3={}'.format(orig_a, orig_c))

client = Client(a, c)

# The client comes up behind a and is reached from the far end. That
# exchange is also what teaches the mesh where it is: a fresh client
# has only sent multicast, most of which is filtered.
client.move_to(a)
addr = client.wait_addr()
b.dbg('client {} is {}'.format(client.mac, addr))
c.wait_until_succeeds('ping -c 3 {}'.format(addr), TIMEOUT)

# a claims the client and the mesh has learned it sits behind a.
wait_claimed(a, client.mac)
wait_announced(b, client.mac, orig_a)

# It roams to the other end and stays reachable from the node it left.
client.move_to(c)
client.wait_addr()
a.wait_until_succeeds('ping -c 3 {}'.format(addr), TIMEOUT)

# The claim moved and the announcement was replaced, not added to. The
# middle node hosts the client neither before nor after, so it holds an
# announcement in both cases.
wait_claimed(c, client.mac)
wait_announced(b, client.mac, orig_c)
wait_withdrawn(b, client.mac, orig_a)

finish()
