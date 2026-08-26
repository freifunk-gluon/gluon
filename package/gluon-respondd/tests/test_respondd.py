#!/usr/bin/env python3
import sys
from pynet import *
import asyncio
import time
import json

a = Node()
b = Node()

connect(a, b)

start()

b.wait_until_succeeds("ping -c 5 node1")


def query_neighbor_info(request):
    response = b.wait_until_succeeds(
        f"gluon-neighbour-info -d ff02::2:1001 -p 1001 -r {request} -i vx_eth2_mesh -c 2"
    )

    # build json array line by line
    ret = [json.loads(l) for l in response.split("\n")]

    b.dbg(f"{request.lower()}:\n{json.dumps(ret, indent=4)}")
    return ret


neighbours = query_neighbor_info("neighbours")

vx_eth2_mesh_addr_a = a.succeed("cat /sys/class/net/vx_eth2_mesh/address")
vx_eth2_mesh_addr_b = b.succeed("cat /sys/class/net/vx_eth2_mesh/address")

res0 = neighbours[0]["batadv"]
res1 = neighbours[1]["batadv"]
if vx_eth2_mesh_addr_a in res0:
    res = res0
else:
    res = res1

batadv_neighbours = res[vx_eth2_mesh_addr_a]["neighbours"]

if vx_eth2_mesh_addr_b in batadv_neighbours:
    print("Node 1 was successfully found in neighbours of node 2.")
else:
    print("ERROR: Node 1 was not found in neighbours of node 2.")
    exit(1)

finish()
