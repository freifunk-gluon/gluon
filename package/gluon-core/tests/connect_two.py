#!/usr/bin/env python3
"""Two directly connected nodes see each other and can ping."""
from pynet import start, finish
from meshlib import pair, wait_neighbours, wait_connected, ping

a, b = pair()

start()

wait_neighbours(a, 1)
wait_neighbours(b, 1)
wait_connected(a, b)
wait_connected(b, a)
ping(a, b)
ping(b, a)

finish()
