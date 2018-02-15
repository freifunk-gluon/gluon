VPN
===

Gluon supports different options to establish vpn tunnels,
which connect mesh clouds and provide internet access.
Currently the available vpn protocols options are:

- fastd
- L2TP (tunneldigger)

Fastd is a lightweight vpn daemon in userspace, which is
especially designed for embedded hardware. It supports
encryption and authentication.

L2TP is implemented inside the linux kernel and has
therefore performance advantages over fastd. The
disadvantage of L2TP is, that it does not support any
encryption. So everything is sent in plain.

Optional Encryption (fastd only):
---------------------------------

When using fastd, the firmware can allow the user to
decide by itself, whether he want's to use encryption
or not. If the firmware builder doesn't like this, he
is also able to hide (or even forbid) the encryptionless
option to the user.

If you want to allow users to decide by themselves:

- Be sure, the package ``gluon-web-mesh-vpn-fastd`` is enabled in ``site.mk``
- Set the option ``mesh_vpn.fastd.configurable = true`` in ``site.conf``
- On the server side, be sure that ``null`` cipher is allowed and preferred over ``salsa2012+umac``. You can ensure this by inserting the ``method "null";`` entry before the ``method "salsa2012+umac";`` in your site.conf.

Users now should have the choice in expert mode to decide
by themselves, which looks like this:

.. image:: fastd_mode.gif

If you want to ensure, that the correct chipher is chosen,
you can use the following command on a router. You maybe
have to install socat before.

       socat - UNIX-CONNECT:/var/run/fastd.mesh_vpn.socket

