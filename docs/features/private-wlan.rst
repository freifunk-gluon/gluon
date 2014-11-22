Private WLAN
============

It is possible to set up a private WLAN that bridges the WAN port and is seperated from the mesh network.
Please note that you should not enable ``mesh_on_wan`` simultaneously.

The private WLAN can be enabled through the config mode if the package ``gluon-luci-private-wifi`` is installed.
You may also enable a private WLAN using the command line::

  uci set wireless.wan_radio0=wifi-iface
  uci set wireless.wan_radio0.device=radio0
  uci set wireless.wan_radio0.network=wan
  uci set wireless.wan_radio0.mode=ap
  uci set wireless.wan_radio0.encryption=psk2
  uci set wireless.wan_radio0.ssid="$SSID"
  uci set wireless.wan_radio0.key="$KEY"
  uci set wireless.wan_radio0.disabled=0
  uci commit
  wifi

Please replace ``$SSID`` by the name of the WLAN and ``$KEY`` by your passphrase (8-63 characters).
If you have two radios (e.g. 2.4 and 5 GHz) you need to do this for radio0 and radio1.

It may also be disabled by running::

  uci set wireless.wan_radio0.disabled=1
  uci commit
  wifi
