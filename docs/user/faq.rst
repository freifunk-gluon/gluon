Frequently Asked Questions
==========================

.. _faq-hardware:

What hardware is supported?
~~~~~~~~~~~~~~~~~~~~~~~~~~~
A table with hardware supported by Gluon can be found on the `OpenWrt Wiki`_.
If you want to find out if your device can potentially be supported 
have a look at :doc:`../dev/hardware` for detailed hardware requirements.

.. _OpenWrt Wiki: https://openwrt.org/toh/views/toh_gluon_supported

.. _faq-dns:

Why does DNS not work on the nodes?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gluon nodes will ignore the DNS server on the WAN port for everything except
the mesh VPN, which can lead to confusion.

All normal services on the nodes exclusively use the DNS server on the mesh
interface. This DNS server must be announced in router advertisements (using
*radvd* or a similar software) from one or more central servers in meshes based
on *batman-adv*. If your mesh does not have global IPv6 connectivity, you can setup
your *radvd* not to announce a default route by setting the *default lifetime* to 0;
in this case, the *radvd* is only used to announce the DNS server.
