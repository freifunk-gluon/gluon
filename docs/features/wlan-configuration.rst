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
configured in the site.conf. The channel width will be reset to the one configured for the radio
(see `Per-radio settings`_) or the site.conf. If you need to preserve
these settings during upgrades you can configure this via the uci section ``gluon-core.wireless``::

  uci set gluon.wireless.preserve_channels='1'

When channels should be preserved, toggling the outdoor mode will have no effect on the channel settings.
Therefore, the Outdoor mode settings won't be displayed in config mode.
Keep in mind that nodes running wifi interfaces on custom channels can't mesh with default nodes anymore!

Per-radio settings
------------------

The transmission power and the channel width can be configured for each radio,
in config mode or using UCI on the node. These settings are stored in the
``wireless_radio`` sections of ``/etc/config/gluon``, which identify a radio by
its path, as radio names may change. Radios of a PHY supporting multiple radios
share the path and are told apart by their ``radio`` index. The sections are
created on upgrade for all radios with a path:

.. code-block:: sh

  uci show gluon | grep wireless_radio
  uci show wireless | grep '\.path='

Set the channel width of a radio in MHz (20, 40, 80 or 160), overriding the
``channel_width`` of the site configuration. Other values are ignored. If the
radio does not support it, the widest supported channel width is used:

.. code-block:: sh

  uci set gluon.@wireless_radio[1].channel_width='40'
  uci commit gluon

Set the transmission power of a radio in dBm, as listed by
``iwinfo <interface> txpowerlist`` for one of its wireless interfaces (e.g.
``client1``):

.. code-block:: sh

  uci set gluon.@wireless_radio[1].txpower='17'
  uci commit gluon

Delete an option to return to the default. To apply the configuration, run
``gluon-reconfigure && wifi reconf``. The transmission power in
``/etc/config/wireless`` is overwritten by this setting, so it must not be
changed there. The channel width has no effect while channels are preserved
(see `Upgrade behaviour`_).

Role Adjustments
----------------

Besides the :doc:`../features/configmode`, the used modes of each band can be configured using UCI on the node.

Enable Mesh on all interfaces using the 2.4GHz band:

.. code-block:: sh

  uci add_list gluon.band_2g.role='mesh'
  uci commit gluon

Disable Mesh on all interfaces using the 2.4GHz band:

.. code-block:: sh

  uci del_list gluon.band_2g.role='mesh'
  uci commit gluon

To apply this configuration change run:

.. code-block:: sh

  gluon-reconfigure && wifi reconf
