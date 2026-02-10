Wired mesh (Mesh-on-WAN/LAN)
############################

In addition to meshing over WLAN and VPN, it is also possible to
configure wired meshing over the LAN or WAN ports. This allows
nodes to be connected directly or over wireless bridges.

Mesh-on-WAN can be enabled in addition to the mesh VPN, so multiple nodes
in the same local network that is used as VPN uplink can also mesh directly.
Enabling Mesh-on-WAN should be avoided if the local network is also bridged with
a WLAN access point, as meshing over batman-adv causes large amounts of
multicast traffic, which will take up a lot of airtime.

Enabling Mesh-on-LAN replaces the normal "client network" function
of the LAN ports, as client network ports may never be connected (so care must be taken to always
enable Mesh-on-LAN before connecting two nodes' LAN ports).

Wired mesh encapsulation
************************

Since version 2018.1, Gluon supports encapsulating wired mesh traffic in
`VXLAN <https://en.wikipedia.org/wiki/Virtual_Extensible_LAN>`_, a new standard with
use cases similar to VLANs, but a much greater ID space of 24bit; in addition, VXLAN
packets pass through VLAN-aware switches without any special configuration.

Encapsulating mesh traffic has two advantages:

* By using a different VXLAN ID for each site and mesh domain, accidental
  wired mesh connections between nodes of different domains will be prevented.
  This has special importance when nodes migrate between domains automatically,
  as currently possible through different site-specific packages.
* While batman-adv traffic does not interact with non-mesh traffic in the same wired
  network in any way (so Gluon nodes can mesh over existing wired networks), this is
  not the case for layer 3 mesh protocols like Babel. Encapsulating the traffic allows
  to distinguish mesh traffic from unrelated packets.

As enabling VXLAN encapsulation will prevent wired mesh communication with old nodes
that do not support VXLAN yet, VXLANs can be enabled per-domain using the site configuration
setting *mesh.vxlan*. VXLAN is enabled by default in multidomain setups; in single-domain
site configurations, the *mesh.vxlan* setting is mandatory. We recommend to enable
VXLAN encapsulation in all new sites and domains.

Non-encapsulated ("legacy") wired meshing will be removed in a future Gluon release.
We cannot give a concrete timeframe for the removal yet; a missing prerequisite is the
implementation of a robust migration path for existing deployments.

Configuration
*************

Both Mesh-on-WAN and Mesh-on-LAN can be configured on the "Network" page
of the *Advanced settings* (if the package ``gluon-web-network`` is installed).

It is also possible to enable Mesh-on-WAN and Mesh-on-LAN by default by adding
the ``mesh`` role to the ``interfaces.*.default_roles`` options in your
:ref:`site.conf<user-site-interfaces>`.


.. _wired-mesh-commandline:

Commandline
===========

Starting with release 2022.1, the wired network configuration is rebuilt from ``/etc/config/gluon``
upon each ``gluon-reconfigure``.
Therefore the network configuration is overwritten at least with every firmware upgrade.

Every interface has a list of roles assigned to it which can be ``client``, ``mesh`` or ``uplink``.

When the client role is assigned to an interface in combination with other roles
(like 'client', 'mesh' in the Mesh-on-LAN example below), the other roles take
precedence, enabling mesh but not client in the previous example.

The setup/config-mode interface is every interface with the role ``client`` which makes removing
it from interfaces not only unnecessary, but generally unrecommended.

In order to make persistent changes to the router's configuration it's necessary to:

* change the sections in ``/etc/config/gluon`` e.g. using uci (see examples below)
* call ``gluon-reconfigure`` to re-generate ``/etc/config/network``
* apply the networking changes, either through executing ``service network restart`` or by performing a ``reboot``

Enable Mesh-on-WAN

.. code-block:: sh

  uci add_list gluon.iface_wan.role='mesh'
  uci commit gluon

Disable Mesh-on-WAN

.. code-block:: sh

  uci del_list gluon.iface_wan.role='mesh'
  uci commit gluon

Enable Mesh-on-LAN

.. code-block:: sh

  uci add_list gluon.iface_lan.role='mesh'
  uci commit gluon

Disable Mesh-on-LAN

.. code-block:: sh

  uci del_list gluon.iface_lan.role='mesh'
  uci commit gluon

For devices with a single interface, instead of `iface_lan` and `iface_wan` configuration is
done with `iface_single`.

Enable Mesh-on-Single

.. code-block:: sh

  uci add_list gluon.iface_single.role='mesh'
  uci commit gluon

Disable Mesh-on-Single

.. code-block:: sh

  uci del_list gluon.iface_single.role='mesh'
  uci commit gluon

Furthermore it is possible to make use of 802.1Q VLAN.
The following statements would create a VLAN with id 8 on ``eth0`` and join the mesh network with it

.. code-block:: sh

  uci set gluon.iface_lan_vlan8=interface
  uci set gluon.iface_lan_vlan8.name='eth0.8'
  uci add_list gluon.iface_lan_vlan8.role='mesh'
  uci commit gluon

Other VLAN-interfaces could be configured on the same parent interface in order to have
all three roles available on ``eth0`` without having them interfere with each other.
This feature comes in especially handy for the persistent configuration of virtual machines
as offloader for bigger installations.

A ``reboot`` is not sufficient to apply an altered configuration; calling ``gluon-reconfigure`` before is
mandatory in order for changes to take effect.

Please note that this configuration has changed in Gluon 2022.1. Using
the old commands on 2022.1 and later will break the corresponding options
in the *Advanced settings*.
