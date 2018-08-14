MAC addresses
=============

Many devices don't have enough unique MAC addresses assigned by the vendor
(in batman-adv, each mesh interface needs an own MAC address that must be unique
mesh-wide).

Gluon tries to solve this issue by using a hash of the primary MAC address as a
45 bit MAC address prefix. The resulting 8 addresses are used as follows:

* 0: client0; WAN
* 1: mesh0
* 2: ibss0
* 3: wan_radio0 (private WLAN); batman-adv primary address
* 4: client1; LAN
* 5: mesh1
* 6: ibss1
* 7: wan_radio1 (private WLAN); mesh VPN
