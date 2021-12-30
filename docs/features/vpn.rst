Mesh-VPN
========

Gluon integrates several OSI-Layer 2 tunneling protocols to
enable interconnects between local meshes and provide
internetwork access. Available protocols currently are:

- fastd
- L2TPv3 (via tunneldigger)

fastd is a lightweight userspace tunneling daemon, that
implements cipher suites that are specifically designed
to work well on embedded devices. It offers encryption
and authentication. Its primary drawback are the necessary
context-switches when forwarding packets.

L2TPv3 is an in-kernel tunneling protocol that performs well,
but offers no security properties by itself.
The brokering of the tunnel happens through tunneldigger,
its primary drawback being the lack of IPv6 support.

fastd
-----

Configurable Cipher
^^^^^^^^^^^^^^^^^^^


From the site configuration fastd can be allowed to offer
toggleable encryption in the config mode with the intent to
increase throughput, although in practice the gain is minimal.

**Site configuration:**

1) Add the feature ``web-mesh-vpn-fastd`` in ``site.mk``
2) Set ``mesh_vpn.fastd.configurable = true`` in ``site.conf``
3) Optionally add ``null`` to the ``mesh_vpn.fastd.methods`` table if you want "Performance mode" as default (not recommended)

**Gateway configuration:**

1) Prepend the ``null`` cipher in fastd's method list


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
