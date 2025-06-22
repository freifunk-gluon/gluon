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

.. _faq-lost-settings:

Which settings are retained or migrated upon an update?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gluon provides a :doc:`../dev/web/config-mode`, which allows the configuration via webinterface.
Under the hood it uses UCI and sets options according to the users input.

There's a recurring misconception that all UCI settings are retained and migrated across
updates unconditionally. A settings presence does not imply this on its own.

Only if a setting is either configurable via the setupmode, or explicitly referenced
in this documentation - the wiki or other inofficial places do not count - it is supposed to
survive the update process.

All other options may be overridden, might disappear or lose functionality after a firmware update or already
after calling gluon-reconfigure.

.. _faq-gluon-preserve:

How can I retain options upon updates anyway?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For settings in the sections *network* and *system*, the option *gluon_preserve* can be set to true
in order to preserve the sections. However, this is still at a high risk and may result in broken setups.

There are two conditions that must hold:

- The preserved section must not already exist after OpenWrt's and
  Gluon's setup scripts ran. Modifying existing sections is currently
  unsupported.
- Preserved sections must be named, so it can be detected whether a
  section conflicts with a preexisting one.

Furthermore, this merely ensures the existence, not the functionality of a UCI setting after the update.
