DNS forwarder
=============

A Gluon node can be configured to act as a DNS forwarder. Requests for the
next-node hostname can be answered locally, without querying the upstream
resolver.

**Note:** While this reduces answer time and allows to use the next-node
hostname without upstream connectivity, this feature should not be used for
next-node hostnames that are FQDN when the zone uses DNSSEC.

One or more upstream resolvers can be configured in the *dns.servers* setting.
When *next_node.name* is set, A and/or AAAA records for the next-node IP
addresses are placed in the dnsmasq configuration.

::

  dns = {
    servers = { '2001:db8::1', },
  },

  next_node = {
    name = 'nextnode',
    ip6 = '2001:db8:8::1',
    ip4 = '198.51.100.1',
  }
