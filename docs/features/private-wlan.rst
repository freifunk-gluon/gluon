Private WLAN
============

It is possible to set up a private WLAN that bridges the uplink port and is separated from the mesh network.
Please note that you should not enable Wired Mesh on the uplink port at the same time.

The private WLAN is encrypted using WPA2 by default. On devices with enough flash and a supported radio,
WPA3 or WPA2/WPA3 mixed-mode can be used instead of WPA2. For this to work, the ``wireless-encryption-wpa3``
feature has to be enabled as a feature.

It is recommended to enable IEEE 802.11w management frame protection for WPA2/WPA3 networks, however this
can lead to connectivity problems for older clients. In this case, management frame protection can be
made optional or completely disabled in the advanced settings tab.

The private WLAN can be enabled through the config mode if the package ``gluon-web-private-wifi`` is installed.
You may also enable a private WLAN using the command line::

  SSID="privateWLANname"
  KEY="yoursecret1337password"

  uci add_list gluon.band_2g.role=private
  uci add_list gluon.band_5g.role=private
  uci set gluon.wireless.private_encryption=psk2
  uci set gluon.wireless.private_ssid="$SSID"
  uci set gluon.wireless.private_key="$KEY"
  uci commit gluon
  gluon-reconfigure
  wifi

Please replace ``$SSID`` by the name of the WLAN and ``$KEY`` by your passphrase (8-63 characters).
If you have two radios (e.g. 2.4 and 5 GHz) you need to add the role to both bands.

It may also be disabled by running::

  uci del_list set gluon.band_2g.role=private
  uci commit gluon
  wifi
