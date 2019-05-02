# Gluon wlan encrypt
Encrypt wireless networks in a non-Freifunk setup.

This package allows to encrypt 802.11s and infrastructure networks using a pre shared key (psk).

This setup results in passwords being stored in plain-text. Site-configuration, Firmware-downloads and
Devices must be protected against unauthorized access

*make sure to use exclude hostapd-mini site.mk*

Example configuration:

```lua
wlan_encryption_psk = { mesh = '802.11s.passwd', ap = ' infrastructure.passwd', },
```
