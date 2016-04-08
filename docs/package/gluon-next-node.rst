gluon-next-node
===============

This package provides a virtual interface (tied to *br-client*) called *local-node*
using the same MAC, IP4 and IP6 across all nodes in a mesh. Thus, the node that
the client is currently connected to, can always be reached under a known address.

The IP6 is marked es deprecated to prevent it from being used as a source
address for packages originating from a node.

site.conf
---------

next_node.mac
    MAC to be set on the interface.

next_node.ip4
    IP4 to be set on the interface.

next_node.ip6
    IP6 to be set on the interface.
