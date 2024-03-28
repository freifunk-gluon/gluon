WLAN configuration
==================

Gluon allows to configure 2.4GHz and 5GHz radios independently. The configuration
may include one or both of the two networks "client" (AP mode) and "mesh" (802.11s
mode), which can be used simultaneously. See :doc:`../user/site` for details on the
configuration.

Outdoor mode
------------

Configuring the node for outdoor use tunes the 5 GHz radio to a frequency and transmission power that conforms with the local regulatory requirements. 
It also enables dynamic frequency selection (DFS; radar detection).
At the same time, mesh functionality is disabled as it requires neighbouring nodes to stay on the same channel permanently.

Upgrade behaviour
-----------------

For each of these networks, the site configuration may define a `disabled` flag (by
default, all configured networks are enabled). This flag is merely a default setting,
on upgrades the existing setting is always retained (as this setting may have been changed
by the user). This means that it is not possible to enable or disable an existing network
configurations during upgrades.

During upgrades the wifi channel of the 2.4GHz and 5GHz radio will be restored to the channel
configured in the site.conf. The channel width will be reset to Gluon's default. If you need to preserve
these settings during upgrades you can configure this via the uci section ``gluon-core.wireless``::

  uci set gluon.wireless.preserve_channels='1'

When channels should be preserved, toggling the outdoor mode will have no effect on the channel settings.
Therefore, the Outdoor mode settings won't be displayed in config mode.
Keep in mind that nodes running wifi interfaces on custom channels can't mesh with default nodes anymore!
