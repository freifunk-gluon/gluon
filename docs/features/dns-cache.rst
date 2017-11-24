DNS caching
===========

User experience may be greatly improved when dns is accelerated. Also, it
seems like a good idea to keep the number of packages being exchanged
between node and gateway as small as possible. In order to do this, a
DNS cache may be used on a node. The dnsmasq instance listening on port
53 on the node will be reconfigured to answer requests, use a list of
upstream servers and a specific cache size if the options listed below are
added to site.conf. Upstream servers are the DNS servers which are normally
used by the nodes to resolve hostnames (e.g. gateways/supernodes).

There are the following settings:
    servers
    cacheentries

If both options are set the node will cache as much DNS records as set with
'cacheentries' in RAM. The 'servers' list will be used to resolve the received
DNS queries if the request cannot be answered from cache.  If these settings do
not exist, the cache is not intialized and RAM usage will not increase.  Note
that not setting 'servers' here defeates the purpose; once the routers all
announce the "next node" address for DNS, there is no way for nodes to
automatically determine DNS servers.  They have to be baked into the firmware.

When next_node.name is set, an A record and an AAAA record for the
next-node IP address are placed in the dnsmasq configuration. This means that the content
of next_node.name may be resolved even without upstream connectivity. It is suggested to use
the same name as the DNS server provides: e.g nextnode.yourdomain.net (This way the name also 
works if client uses static DNS Servers). Hint: If next_node.name does not contain a dot some 
browsers would open the searchpage instead.

::

  dns = {
    cacheentries = 5000,
    servers = { '2001:db8::1', },
  },

  next_node = {
    name = 'nextnode.yourdomain.net',
    ip6 = '2001:db8:8::1',
    ip4 = '198.51.100.1',
  }


The cache will be initialized during startup.
Each cache entry will occupy about 90 bytes of RAM.
