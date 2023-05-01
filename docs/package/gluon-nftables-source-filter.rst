gluon-nftables-source-filter
============================

The *gluon-nftables-source-filter* package adds an additional layer-2 filter
ruleset to prevent unreasonable traffic entering the network via the nodes.
Unreasonable means traffic entering the mesh via a node which source IP does
not belong to the configured IP space.

You may first check if there is a certain proportion of unreasonable traffic,
before adding this package to the firmware image. Furthermore, you should not
use this package if some kind of gateway or upstream network is provided by
a device connected to the client port.

site.conf
---------

prefix4 : optional
    - IPv4 subnet

prefix6 :
    - IPv6 subnet

extra_prefixes6 : optional
    - list of additional IPv6 subnets

Example::

  prefix4 = '198.51.100.0/21',
  prefix6 = '2001:db8:8::/64',
  extra_prefixes6 = {
    '2001:db8:9::/64',
    '2001:db8:100::/60',
  },
