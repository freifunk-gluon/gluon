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
the ``mesh`` role to the ``interfaces.*.default_roles`` options in site.conf.

Commandline
===========

Enable Mesh-on-WAN::

  uci set network.mesh_wan.disabled=0
  uci commit network

Disable Mesh-on-WAN::

  uci set network.mesh_wan.disabled=1
  uci commit network

Enable Mesh-on-LAN::

  uci set network.mesh_lan.disabled=0
  for ifname in $(cat /lib/gluon/core/sysconfig/lan_ifname); do
    uci del_list network.client.ifname=$ifname
  done
  uci commit network

Disable Mesh-on-LAN::

  uci set network.mesh_lan.disabled=1
  for ifname in $(cat /lib/gluon/core/sysconfig/lan_ifname); do
    uci add_list network.client.ifname=$ifname
  done
  uci commit network

Please note that this configuration has changed in Gluon 2016.1. Using
the old commands on 2016.1 and later will break the corresponding options
in the *Advanced settings*.
