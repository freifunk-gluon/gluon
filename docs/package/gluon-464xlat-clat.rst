gluon-464xlat-clat
==================

This package provides the kernel module and functionality required to support
ipv4 clients on an ipv6-only backbone.

Assumptions
-----------

* Clients will be given IPv4 addresses by a dhcp daemon that runs on each node.
  gluon-ddhcpd is a great choice for this.
* There is a component on the network that does plat on the default network
  64:ff9b::/96. https://github.com/FreifunkMD/jool-docker.git can do this.

Limitations
-----------
* When roaming, clients will experience temporary loss of IPv4 connectivity

site.conf
---------

clat_range : mandatory
    - infrastructure net (ULA) from which a /96 clat prefix will be generated.
    - This must be a /48 prefix.
    - This can be the same for each community and is pre-registered at https://wiki.freifunk.net/IP-Netze#IPv6 as part of fdff:ffff:ff00::/40

Example::

  {
	clat_range = 'fdff:ffff:ffff::/48', 
  }

