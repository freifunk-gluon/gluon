WLAN configuration
==================

Gluon allows to configure 2.4GHz and 5GHz radios independently. The configuration
may include any or all of the three networks "client" (AP mode), "mesh" (802.11s
mode) and "ibss" (adhoc mode), which can be used simultaneously (using "mesh" and
"ibss" at same time should be avoided though as weaker hardware usually can't handle the additional
load). See :doc:`../user/site` for details on the configuration.

Upgrade behaviour
-----------------

For each of these networks, the site configuration may define a `disabled` flag (by
default, all configured networks are enabled). This flag is merely a default setting,
on upgrades the existing setting is always retained (as this setting may have been changed
by the user). This means that is is not possible to enable or disable an existing network
configurations during upgrades.

For the "mesh" and "ibss" networks, the default setting only has an effect if none
of the two has existed before. If a new configuration has been added for "mesh" or "ibss",
while the other of the two has already existed before, the enabled/disabled state of the
existing configuration will also be set for the new configuration.

This allows upgrades to change from IBSS to 11s and vice-versa while retaining the
"wireless meshing is enabled/disabled" property configured by the user regardless
of the used mode.

During upgrades the wifi channel of the 2.4GHz and 5GHz radio will be restored to the channel
configured in the site.conf. If you need to preserve a user defined wifi channel during upgrades
you can configure this via the uci section ``gluon-core.wireless``::

  uci set gluon-core.@wireless[0].preserve_channels='1'

Keep in mind that nodes running wifi interfaces on custom channels can't mesh with default nodes anymore!
