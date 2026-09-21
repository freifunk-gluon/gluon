#!/usr/bin/env python3
"""Boot one node and print the packages it has installed, one per line.
Used by run.py to decide which package tests apply to an image."""
from pynet import Node, start, finish

a = Node()

start()

packages = a.succeed(
    'apk info 2>/dev/null || opkg list-installed 2>/dev/null | cut -d" " -f1')

print('--- packages ---')
for line in sorted(set(packages.split())):
    print(line)

finish()
