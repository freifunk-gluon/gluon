gluon-nftables-limit-arp
========================

The *gluon-nftables-limit-arp* package adds filters to limit the
amount of ARP requests client devices are allowed to send into the
mesh.

The limits per client device, identified by its MAC address, are
6 packets per minute and 1 per second per node in total.
A burst of up to 50 ARP requests is allowed until the rate-limiting
takes effect (see ``--limit-burst`` in ``nftables(8)``).

Furthermore, ARP requests for a target IP already present in the
batman-adv DAT cache are excluded from rate-limiting, in regard
to both counting and filtering, as batman-adv will be able
to respond locally without a burden for the mesh. Therefore, this
limiter should not affect popular target IP addresses, like those
of gateways or nameservers.

However it mitigates the impact on the mesh when a larger range of
its IPv4 subnet is being scanned, which would otherwise result in
a significant amount of ARP chatter, even for unused IP addresses.

This package is installed by default if the selected routing
feature is *mesh-batman-adv-15*.
It can be unselected via::

    GLUON_SITE_PACKAGES := \
      -gluon-nftables-limit-arp
