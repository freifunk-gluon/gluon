Private WLAN
============

It is possible to set up a private WLAN that bridges the uplink port and is separated from the mesh network.
Please note that you should not enable Wired Mesh on the uplink port at the same time.

The private WLAN is encrypted using WPA2 by default. On devices with enough flash and a supported radio,
WPA3 or WPA2/WPA3 mixed-mode can be used instead of WPA2. For this to work, the ``wireless-encryption-wpa3``
feature has to be added to ``GLUON_FEATURES``.

It is recommended to enable IEEE 802.11w management frame protection for WPA2/WPA3 networks, however this
can lead to connectivity problems for older clients. In this case, management frame protection can be
made optional or completely disabled in the advanced settings tab.

The private WLAN can be enabled through the config mode if the package ``gluon-web-private-wifi`` is installed.
You may also enable a private WLAN using the command line::

  RID=0
  SSID="privateWLANname"
  KEY="yoursecret1337password"

  uci set wireless.wan_radio$RID=wifi-iface
  uci set wireless.wan_radio$RID.device=radio$RID
  uci set wireless.wan_radio$RID.network=wan
  uci set wireless.wan_radio$RID.mode=ap
  uci set wireless.wan_radio$RID.encryption=psk2
  uci set wireless.wan_radio$RID.ssid="$SSID"
  uci set wireless.wan_radio$RID.key="$KEY"
  uci set wireless.wan_radio$RID.disabled=0
  uci set wireless.wan_radio$RID.macaddr=$(lua -e "print(require('gluon.util').generate_mac(3+4*$RID))")
  uci commit
  wifi

Please replace ``$SSID`` by the name of the WLAN and ``$KEY`` by your passphrase (8-63 characters).
If you have two radios (e.g. 2.4 and 5 GHz) you need to do this for radio0 and radio1.

It may also be disabled by running::

  uci set wireless.wan_radio0.disabled=1
  uci commit
  wifi
