#!/usr/bin/env python3
"""Three fully meshed nodes all see and reach each other."""
from pynet import start, finish
from meshlib import full_mesh, wait_neighbours, wait_all_connected, ping

nodes = full_mesh(3)

start()

for n in nodes:
    wait_neighbours(n, 2)

wait_all_connected(nodes)

for a in nodes:
    for b in nodes:
        if a is not b:
            ping(a, b)

finish()
