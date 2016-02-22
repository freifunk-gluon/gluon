gluon-ebtables-filter-ra-dhcp
=============================

The *gluon-ebtables-filter-ra-dhcp* package tries to prevent common
misconfigurations (i.e. connecting the client interface of a Gluon
node to a private network) from causing issues for either of the
networks.

The rules are the following:

* DHCP requests, DHCPv6 requests and Router Solicitations may only be sent from clients to the mesh, but aren't forwarded
  from the mesh to clients
* DHCP replies, DHCPv6 replies and Router Advertisements from clients aren't forwarded to the mesh
