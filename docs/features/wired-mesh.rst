Wired mesh (Mesh-on-WAN/LAN)
============================

In addition to meshing over WLAN and VPN, it is also possible to
configured wired meshing over the LAN or WAN ports. This allows
nodes to be connected directly or over wireless bridges.

Mesh-on-WAN can be enabled in addition to the mesh VPN, so multiple nodes
in the same local network that is used as VPN uplink can also mesh directly.
Enabling Mesh-on-WAN should be avoided if the local network is also bridged with
a WLAN access point, as meshing over batman-adv causes large amounts of
multicast traffic, which will take up a lot of airtime.

Enabling Mesh-on-LAN will replace the normal "client network" function
of the LAN ports, as client network ports may never be connected (so care must be taken to always
enable Mesh-on-LAN before connecting two nodes' LAN ports).

Configuration
~~~~~~~~~~~~~

Both Mesh-on-WAN and Mesh-on-LAN can be configured on the "Network" page
of the *Expert Mode* (if the package ``gluon-luci-portconfig`` is installed).

It is also possible to enable Mesh-on-WAN and Mesh-on-LAN by default by
adding ``mesh_on_wan = true`` and ``mesh_on_lan = true`` to ``site.conf``.

Commandline configuration
-------------------------

Mesh-on-WAN
...........

It's possible to enable Mesh-on-WAN like this::

  uci set network.mesh_wan.auto=1
  uci commit

It may be disabled by running::

  uci set network.mesh_wan.auto=0
  uci commit


Mesh-on-LAN
...........

Configuring Mesh-on-LAN is a bit more complicated::

  uci set network.mesh_lan.auto=1
  for ifname in $(cat /lib/gluon/core/sysconfig/lan_ifname); do
    uci del_list network.client.ifname=$ifname
  done
  uci commit

It may be disabled by running::

  uci set network.mesh_lan.auto=0
  for ifname in $(cat /lib/gluon/core/sysconfig/lan_ifname); do
    uci add_list network.client.ifname=$ifname
  done
  uci commit

Please note that this configuration has changed in Gluon v2016.1. Using
the old commands on v2016.1 will break the corresponding Expert Mode
settings.
