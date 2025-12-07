gluon-mesh-vpn-sqm
==================

Tools for Smart Queue Management (SQM) can be used to reduce bufferbloat latency on the mesh-VPN connection.
For this, CAKE is used as a QoS mechanism on compatible VPN providers (currently only fastd supported).

As CAKE requires must know the upper limits of the connection speed, it is enabled when throughput limits are configured for the mesh-VPN.
This limit s are then used for traffic shaping.
It is only enabled on devices offering at least 200MB of system memory.

For more information about the technical details, see the
(`OpenWrt wiki <https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm>`_).

Support can be activated by including the `mesh-vpn-sqm` feature in the :doc:`image-customatization.lua <../user/site>`.
