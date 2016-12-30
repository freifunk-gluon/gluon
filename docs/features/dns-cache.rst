DNS-Caching
===========
User experience may be greatly improved when dns is accelerated. Also it
seems like a good idea to keep the number if packages being exchanged
between node and gateway as small as possible. In order to do this, a
dns-cache may be used on a node. The dnsmasq instance listening on port
53 in the node will be re-configured to answer requests, use a list of
upstream servers and a specific cache size if the below options are
added to site.conf All settings are optional, though if no dns server is
set, the configuration will not be altered by gluon-core.

Besides caching dns requests from clients, the next_node-addresses are set to
resolve to a configurable name that may optionally be placed in next_node.name.

::

  dns = {
    cacheentries = 5000,
    servers = { '2001:db8::1', },
  },
  
  next_node = {
    name = 'nextnode',
    ip6 = '2001:db8:8::1',
    ip4 = '198.51.100.1',
  }


The cache will be initialized during startup. Each cache entry will use roughly
90 Bytes of main memory.
