WLAN configuration
==================

Gluon allows to configure 2.4GHz and 5GHz radios independently. The configuration
may include one or both of the two networks "client" (AP mode) and "mesh" (802.11s
mode), which can be used simultaneously. See :doc:`../user/site` for details on the
configuration.

Upgrade behaviour
-----------------

For each of these networks, the site configuration may define a `disabled` flag (by
default, all configured networks are enabled). This flag is merely a default setting,
on upgrades the existing setting is always retained (as this setting may have been changed
by the user). This means that it is not possible to enable or disable an existing network
configurations during upgrades.

During upgrades the wifi channel of the 2.4GHz and 5GHz radio will be restored to the channel
configured in the site.conf. If you need to preserve a user defined wifi channel during upgrades
you can configure this via the uci section ``gluon-core.wireless``::

  uci set gluon-core.@wireless[0].preserve_channels='1'

Keep in mind that nodes running wifi interfaces on custom channels can't mesh with default nodes anymore!
