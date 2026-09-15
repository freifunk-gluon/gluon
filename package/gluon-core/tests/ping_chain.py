#!/usr/bin/env python3
"""Three nodes in a chain a - b - c: traffic from a jumps over b to c."""
from pynet import start, finish
from meshlib import chain, wait_neighbours, wait_connected, ping

a, b, c = chain(3)

start()

# the middle node sees both ends
wait_neighbours(b, 2)

# the ends learn a route to each other across the middle hop
wait_connected(a, c)
wait_connected(c, a)

# end-to-end over two hops
ping(a, c)
ping(c, a)

finish()
