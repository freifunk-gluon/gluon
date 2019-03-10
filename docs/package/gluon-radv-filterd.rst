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
advertisements originating  from it. All nodes announcing router advertisement
**with** a default lifetime greater than 0 are being considered as candidates.

In case a router is not a batman-adv originator itself, its TQ is defined by
the originator it is connected to. This lookup uses the batman-adv global
translation table.

Initially the router is the selected by choosing the candidate with the
strongest TQ. When another candidate can provide a better TQ metric it is not
picked up as the selected router until it will outperform the currently
selected router by X metric units. The hysteresis threshold is configurable
and prevents excessive flapping of the gateway.

"Local" routers
---------------

The package has functionality to select "local" routers, i.e. those connected
via cable or WLAN instead of via the mesh (technically: appearing in the
``transtable_local``), a fake TQ of 512 so that they are always preferred.
However, if used together with the :doc:`gluon-ebtables-filter-ra-dhcp`
package, these router advertisements are filtered anyway and reach neither the
node nor any other client. You currently have to disable the package or insert
custom ebtables rules in order to use local routers.

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
    - minimal difference in TQ value that another gateway has to be better than
      the currently chosen gateway to become the new chosen gateway
    - defaults to ``20``

Example::

  radv_filterd = {
    threshold = 20,
  }
