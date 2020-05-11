MAC addresses
=============

Many devices don't have enough unique MAC addresses assigned by the vendor
(in batman-adv, each mesh interface needs an own MAC address that must be unique
mesh-wide).

Gluon tries to solve this issue by using a hash of the primary MAC address as a
45 bit MAC address prefix per radio. One additional prefix is dedicated to wired
interfaces as well as the mesh-protocol.

The remaining 3 bits are assigned to the following interfaces / VAPs:

IDs for non-radio interfaces defined so far:
* 0: WAN
* 3: batman-adv primary address
* 4: LAN
* 7: mesh VPN

IDs for radio interfaces defined so far:
* 0: client
* 1: mesh
* 2: owe
* 3: wan_radio (private WLAN)
