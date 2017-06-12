gluon-ebtables-filter-multicast
===============================

The *gluon-ebtables-filter-multicast* package filters out various kinds of
non-essential multicast traffic, as this traffic often constitutes a
disproportionate burden on the mesh network. Unfortunately, this breaks many useful services
(Avahi, Bonjour chat, ...), but this seems unavoidable, as the current Avahi implementation is
optimized for small local networks and causes too much traffic in large mesh networks.

The multicast packets are filtered between the nodes' client bridge (*br-client*) and mesh
interface (*bat0*) on output.


The following packet types are considered essential and aren't filtered:

* ARP (except requests for/replies from 0.0.0.0)
* DHCP, DHCPv6
* ICMPv6 (except Echo Requests (ping) and Node Information Queries (RFC4620)
* IGMP

In addition, the following packet types are allowed to allow experimentation with
layer 3 routing protocols.

* Babel
* OSPF
* RIPng

The following packet types are also allowed:

* BitTorrent Local Peer Discovery (it seems better to have local peers for BitTorrent than sending everything through the internet)
