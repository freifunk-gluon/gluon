#!/usr/bin/env python3
import sys
from pynet import *
import asyncio
import time

a = Node()
b = Node()

connect(a, b)

start()

b.wait_until_succeeds("ping -c 5 node1")

addr = a.succeed('cat /sys/class/net/primary0/address')
result = b.succeed(f'batctl tp {addr}')

print(result)

finish()

