gluon-mesh-batman-adv-brmldproxy
================================

The *gluon-mesh-batman-adv-brmldproxy* package adds configuration
to enable `brmldproxy`_ in Gluon with batman-adv.

If `filter_membership_reports` :ref:`site.conf <user-site-mesh>` is false in the site.conf
then no multicast listener is filtered, but the node will
respond on behalf of any of its local listeners, potentially
reducing duplicate MLD report overhead.

If `filter_membership_reports` :ref:`site.conf <user-site-mesh>` is true in the site.conf
or absent then brmldproxy is additionally configured to
only send MLD reports for routeable IPv6 multicast addresses
and only to detected IPv6 multicast routers. If no such
router is detected or no local listeners for routeable
IPv6 multicast addresses exists then no MLD report is send
into the mesh. Which greatly reduces MLD overhead while
still allowing the usage of layer 3 IPv6 multicast routers.
This is the recommended setting especially in larger meshes.

----

Notable layer 3 IPv6 multicast router implementations:

* pim6sd: https://github.com/troglobit/pim6sd
    * HowTo at DN42: https://dn42.dev/howto/IPv6-Multicast

.. _brmldproxy: https://github.com/T-X/brmldproxy
