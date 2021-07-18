Mesh-VPN
========

Gluon integrates several OSI-Layer 2 tunneling protocols to
enable interconnects between local meshes and provide
internetwork access. Available protocol handlers currently are:

- fastd
- tunneldigger

fastd is a lightweight userspace tunneling daemon, that
implements cipher suites that are specifically designed
to work well on embedded devices. It offers encryption
and authentication. Its primary drawback is the necessary
context switches when forwarding packets.
A kernel-supported L2TPv3 offloading option is available to
work around the context-switching bottleneck but it comes
at the cost of losing the ability to encrypt tunnel connections.

L2TPv3 is an in-kernel tunneling protocol that performs well
but offers no security properties by itself.
The brokering of the tunnel can happen through tunneldigger
or fastd (by using the ``l2tp@null`` method).
Tunneldigger's primary drawback being the lack of IPv6 support.


fastd
-----

Configurable Cipher
^^^^^^^^^^^^^^^^^^^


From the site configuration, fastd can be allowed to offer
toggleable encryption in the config mode with the intent to
increase throughput. The use of the ``l2tp@null`` method with
offloading enabled can provide a considerable performance gain,
especially on weaker embedded hardware.

Outside of that the benefit of using the ``null`` method is minimal.

**Site configuration:**

1) Add the feature ``web-mesh-vpn-fastd`` in ``site.mk``
2) Set ``mesh_vpn.fastd.configurable = true`` in ``site.conf``
3) Optionally, add ``null`` to the ``mesh_vpn.fastd.methods`` table if you want "Performance mode" as default (not recommended)
4) Optionally, if you are using ``l2tp@null`` you will have to add this before ``null`` in your ``mesh_vpn.fastd.methods``

**Gateway configuration:**

If only using the ``null`` method without L2TP and offloading
simply prepend the ``null`` cipher in fastd's method list.

Using the ``l2tp@null`` method with offloading requires a bit
more preparation on the gateway end.

Aside from using a version of fastd that supports this feature,
such as v22 and newer, as well as a kernel that has L2TPv3
support enabled, it is recommended to study the fastd
documentation section pertaining to the ``option-offload``
`configuration option <https://fastd.readthedocs.io/en/stable/manual/config.html#option-offload>`_.
To ensure that ``l2tp@null`` is the preferred ``null`` cipher
make sure to place it before the ``null`` cipher in your
configuration.

Note that in ``multitap`` mode, which is required when using
L2TPv3 offloading, fastd will create one interface per peer
on the gateway's side and it is the administrator's
responsibility to ensure these interfaces are handled
accordingly upon connect and disconnect using scripts and the
``on`` directives.

For example, in batman-adv based setups this could include
adding or removing the interface from the batman-adv device.


**Config Mode:**
The resulting firmware will allow users to choose between secure (encrypted) and fast (unencrypted) transport.

.. image:: fastd_mode.gif

**Unix socket:**
To confirm whether the correct cipher is being used, fastd's unix
socket can be interrogated, after installing for example `socat`.

::

       opkg update
       opkg install socat
       socat - UNIX-CONNECT:/var/run/fastd.mesh_vpn.socket
