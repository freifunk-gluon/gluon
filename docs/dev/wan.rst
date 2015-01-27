WAN support
===========

As the WAN port of a node will be connected to a user's private network, it
is essential that the node only uses the WAN when it is absolutely necessary.
There are two cases in which the WAN port is used:

* Mesh VPN (package ``gluon-mesh-vpn-fastd``
* DNS to resolve the VPN servers' addresses (package ``gluon-wan-dnsmasq``)

After the VPN connection has been established, the node should be able to reach
the mesh's DNS servers and use these for all other name resolution.


Routing tables
~~~~~~~~~~~~~~
As a node may get IPv6 default routes both over the WAN and the mesh, Gluon
uses two routing tables for IPv6. As all normal traffic should go over the mesh,
the mesh routes are added to the default table (table 0). All routes on the WAN interface
are put into table 1 (see ``/lib/gluon/upgrade/110-network`` in ``gluon-core``).

There is also an *ip -6 rule* which routes all IPv6 traffic with a packet mark with the
bit 1 set though table 1.


libpacketmark
~~~~~~~~~~~~~
*libpacketmark* is a library which can be loaded with ``LD_PRELOAD`` and will set the packet mark of all
sockets created by a process in accordance with the ``LIBPACKETMARK_MARK`` environment variable. This allows setting
the packet mark for processes which don't support this themselves. The process must run as root (or at least
with ``CAP_NET_ADMIN``) for this to work.

Unfortunately there's no nice way to set the packet mark via iptables for outgoing packets. The iptables will
run after the packet has been created, to even when the packet mark is changed and the packet is re-routed, the
source address won't be rewritten to the default source address of the newly chosen route. *libpacketmark* avoids
this issue as the packet mark will already be set when the packet is created.

gluon-wan-dnsmasq
~~~~~~~~~~~~~~~~~
To separate the DNS servers in the mesh from the ones on the WAN, the ``gluon-wan-dnsmasq`` package provides
a secondary DNS daemon which runs on ``127.0.0.1:54``. It will automatically use all DNS servers explicitly
configured in ``/etc/config/gluon-wan-dnsmasq`` or received via DNS/RA on the WAN port. It is important that
no DNS servers for the WAN interface are configured in ``/etc/config/network`` and that ``peerdns`` is set to 0
so the WAN DNS servers aren't leaked to the primary DNS daemon.

*libpacketmark* is used to make the secondary DNS daemon send its requests over the WAN interface.

The package ``gluon-mesh-vpn-fastd`` provides an iptables rule which will redirect all DNS requests from processes running
with the primary group ``gluon-fastd`` to ``127.0.0.1:54``, thus making fastd use the secondary DNS daemon.
