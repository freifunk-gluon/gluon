gluon-radv-filterd
==================

This package drops all incoming router advertisements except for the
default router with the best metric according to B.A.T.M.A.N. advanced.

Note that advertisements originating from the node itself (for example
via gluon-radvd) are not affected and considered at all.

Selected router
---------------

The router selection mechanism is independent from the batman-adv gateway mode.
In contrast, the device originating the router advertisement could be any router
or client connected to the mesh, as radv-filterd captures all router
advertisements originating from it. All nodes announcing router advertisement
**with** a default lifetime greater than 0 are being considered as candidates.

In case a router is not a batman-adv originator itself, its metric is defined by
the originator it is connected to. This lookup uses the batman-adv global
translation table.

The metric itself depends on the routing algorithm in use: B.A.T.M.A.N. IV
reports a TQ value between 0 and 255, B.A.T.M.A.N. V reports an estimated
throughput in kbit/s (i.e. ``50000`` means 50 Mbit/s).

Initially the router is selected by choosing the candidate with the strongest
metric. When another candidate can provide a better metric, that outperforms the
currently selected router by X metric units, it will be picked as the new
selected router. The hysteresis threshold is configurable and prevents excessive
flapping of the gateway.

Local routers
-------------

Local routers (i.e. local internet gateways connected to some nodes) that are
connected to the client interface via cable or WLAN instead of via the mesh
(technically: appearing in the transtable_local) are taken into account with the
highest possible metric, so that they are always preferred.

Be aware of problems if you plan to use local routers together with the
:doc:`gluon-ebtables-filter-ra-dhcp` package. These router advertisements are
filtered anyway and reach neither the node nor any other client. Therefore the
use of local routers is not possible as long as the package
``gluon-radv-filterd`` is used.

respondd module
---------------

This package also contains a module for respondd that announces the currently
selected router via the ``statistics.gateway6`` property using its interface MAC
address. Note that this is different from the ``statistics.gateway`` property,
which contains the MAC address of the main B.A.T.M.A.N. adv slave interface of
the selected IPv4 gateway.

site.conf
---------

radv_filterd.threshold : optional
    - minimal difference in metric that another gateway has to be better than
      the currently chosen gateway to become the new chosen gateway
    - the unit follows the routing algorithm in use:

      - B.A.T.M.A.N. IV: TQ points, ``0`` to ``255`` (``20`` is roughly 8% of
        the value range)
      - B.A.T.M.A.N. V: throughput in kbit/s (``20`` is only 20 kbit/s,
        ``50000`` is 50 Mbit/s)

    - ``0`` disables the hysteresis and always selects the best gateway
    - defaults to ``20``

Example::

  radv_filterd = {
    threshold = 20,
  }
