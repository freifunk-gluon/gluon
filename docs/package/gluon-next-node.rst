gluon-next-node
===============

This package provides a virtual interface (tied to *br-client*) called
*local-node* using the same MAC, IPv4 and IPv6 addresses across all nodes in
a mesh. Thus, the node that the client is currently connected to, can always
be reached under a known address.

The IPv6 address is marked as deprecated to prevent it from being used as a
source address for packages originating from a node.

site.conf
---------

next_node.mac
    MAC address to be set on the interface.

next_node.ip4
    IPv4 address to be set on the interface.

next_node.ip6
    IPv6 address to be set on the interface.
