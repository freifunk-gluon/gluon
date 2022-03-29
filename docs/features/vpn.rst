Mesh VPN
========

Gluon integrates several layer 2 tunneling protocols to
allow connections between local meshes through the internet.

Protocol handlers
^^^^^^^^^^^^^^^^^

There are currently three protocol handlers which can be selected
via ``GLUON_FEATURES`` in ``site.mk``:

mesh-vpn-fastd
~~~~~~~~~~~~~~

fastd is a lightweight userspace tunneling daemon that
implements cipher suites that are specifically designed
to work well on embedded devices. It offers encryption
and authentication.
The primary drawback of fastd's encrypted connection modes
is the necessary context switches when forwarding packets.
A kernel-supported L2TPv3 offloading option is available to
work around the context-switching bottleneck, but it comes
at the cost of losing the ability to protect tunnel connections
against eavesdropping or manipulation.

mesh-vpn-tunneldigger
~~~~~~~~~~~~~~~~~~~~~

Tunneldigger always uses L2TPv3, generally achieving the same
performance as fastd with the ``null@l2tp`` method, but offering
no security.
Tunneldigger's primary drawback is the lack of IPv6 support.
It also provides less configurability than fastd.

mesh-vpn-wireguard (experimental)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wireguard is a new tunneling software that offers modern encryption
methods and is implemented in the kernel, resulting in high throughput.
It is implemented in Gluon using the *wgpeerselector* tool.

fastd
^^^^^

Methods
~~~~~~~

fastd offers various different connection "methods" with different
security properties that can be configured in the site configuration.

The following methods are currently recommended:

- ``salsa2012+umac``: Encrypted + authenticated
- ``null+salsa2012+umac``: Unencrypted, authenticated
- ``null@l2tp``: Unencrypted, unauthenticated

Multiple methods can be listed in ``site.conf``. The first listed method
supported by both the node and its peer will be used.

The use of the ``null@l2tp`` method with offloading enabled can provide a
considerable performance gain, especially on weaker embedded hardware.
For L2TP offloading, the ``mesh-vpn-fastd-l2tp`` feature needs to be enabled in
``site.mk``.

Configurable Method
~~~~~~~~~~~~~~~~~~~

From the site configuration, fastd can be allowed to offer
toggleable encryption in the config mode with the intent to
increase throughput.

There is also an older unprotected method ``null``. Use of the newer
``null@l2tp`` method is generally recommended over ``null``, as the
performance gains provided by the latter (compared to the encrypted
and authenticated methods) are very small.

Site configuration
------------------

1)
  Add the feature ``web-mesh-vpn-fastd`` in ``site.mk``
2)
  Set ``mesh_vpn.fastd.configurable = true`` in ``site.conf``
3)
  Optionally, add ``null@l2tp`` to the ``mesh_vpn.fastd.methods`` table if you want
  "Performance mode" as default (not recommended)

Gateway / Supernode Configuration
---------------------------------

When only using the ``null`` or ``null@l2tp`` methods without offloading,
simply add these methods to the front of the method list. ``null@l2tp``
should always appear before ``null`` in the configuration when both are enabled.
fastd v22 or newer is needed for the ``null@l2tp`` method.

It is often not necessary to enable L2TP offloading on supernodes for
performance reasons. Nodes using offloading can communicate with supornodes that
don't use offloading as long as both use the ``null@l2tp`` method.

To enable L2TP offloading on the supornodes as well, it is recommended to study
the fastd documentation section pertaining to the `offload configuration option
<https://fastd.readthedocs.io/en/stable/manual/config.html#option-offload>`_.

Note that in ``multitap`` mode, which is required when using
L2TP offloading, fastd will create one interface per peer
on the supernode's side and it is the administrator's
responsibility to ensure that these interfaces are handled correctly.
In batman-adv-based setups this involves adding the dynamically created
interfaces to an batadv interface using fastd's ``on up`` scripts or some
network configuration daemon like systemd-networkd.

Config Mode
-----------

The resulting firmware will allow users to choose between secure (encrypted) and fast (unencrypted) transport.

.. image:: fastd_mode.gif

To confirm whether the correct cipher is being used, the log output
of fastd can be checked using ``logread``.
