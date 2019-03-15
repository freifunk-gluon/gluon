Welcome to Gluon
================

Gluon is a modular framework for creating OpenWrt-based firmware images for wireless mesh nodes.
Several Freifunk communities in Germany use Gluon as the foundation of their Freifunk firmware.


.. toctree::
   :caption: User Documentation
   :maxdepth: 2

   user/getting_started
   user/site
   user/x86
   user/faq

.. toctree::
   :caption: Features
   :maxdepth: 2

   features/configmode
   features/autoupdater
   features/wlan-configuration
   features/private-wlan
   features/wired-mesh
   features/dns-forwarder
   features/monitoring
   features/multidomain
   features/authorized-keys
   features/roles
   features/vpn

.. toctree::
   :caption: Developer Documentation
   :maxdepth: 2

   dev/basics
   dev/hardware
   dev/packages
   dev/upgrade
   dev/wan
   dev/mac_addresses
   dev/site_library

.. toctree::
   :caption: gluon-web Reference
   :maxdepth: 1

   dev/web/controller
   dev/web/model
   dev/web/view
   dev/web/i18n
   dev/web/config-mode

.. toctree::
   :caption: Packages
   :maxdepth: 1

   package/gluon-client-bridge
   package/gluon-config-mode-domain-select
   package/gluon-ebtables-filter-multicast
   package/gluon-ebtables-filter-ra-dhcp
   package/gluon-ebtables-limit-arp
   package/gluon-ebtables-source-filter
   package/gluon-radv-filterd
   package/gluon-scheduled-domain-switch
   package/gluon-web-admin
   package/gluon-web-logging

.. toctree::
   :caption: Releases
   :maxdepth: 1

   releases/v2018.2
   releases/v2018.1.4
   releases/v2018.1.3
   releases/v2018.1.2
   releases/v2018.1.1
   releases/v2018.1
   releases/v2017.1.8
   releases/v2017.1.7
   releases/v2017.1.6
   releases/v2017.1.5
   releases/v2017.1.4
   releases/v2017.1.3
   releases/v2017.1.2
   releases/v2017.1.1
   releases/v2017.1
   releases/v2016.2.7
   releases/v2016.2.6
   releases/v2016.2.5
   releases/v2016.2.4
   releases/v2016.2.3
   releases/v2016.2.2
   releases/v2016.2.1
   releases/v2016.2
   releases/v2016.1.6
   releases/v2016.1.5
   releases/v2016.1.4
   releases/v2016.1.3
   releases/v2016.1.2
   releases/v2016.1.1
   releases/v2016.1
   releases/v2015.1.2
   releases/v2015.1.1
   releases/v2015.1
   releases/v2014.4
   releases/v2014.3.1
   releases/v2014.3


Supported Devices & Architectures
---------------------------------

ar71xx-generic
^^^^^^^^^^^^^^

* 8devices

  - Carambola 2

* ALFA Network

  - AP121
  - AP121F
  - AP121U
  - Hornet-UB
  - Tube2H
  - N2
  - N5

* Allnet

  - ALL0315N

* AVM

  - Fritz!Box 4020 [#avmflash]_
  - Fritz!WLAN Repeater 300E [#avmflash]_
  - Fritz!WLAN Repeater 450E [#avmflash]_

* Buffalo

  - WZR-HP-AG300H / WZR-600DHP
  - WZR-HP-G300NH
  - WZR-HP-G300NH2
  - WZR-HP-G450H

* D-Link

  - DAP-1330 (A1)
  - DIR-505 (A1, A2)
  - DIR-825 (B1)

* GL Innovations

  - GL-AR150
  - GL-AR300M
  - GL-AR750 [#ath10k]_
  - GL-iNet 6408A (v1)
  - GL-iNet 6416A (v1)

* Linksys

  - WRT160NL

* Netgear

  - WNDR3700 (v1, v2, v5)
  - WNDR3800
  - WNDRMAC (v2)

* OCEDO

  - Koala [#ath10k]_

* Onion

  - Omega

* OpenMesh

  - A40
  - A60
  - MR600 (v1, v2)
  - MR900 (v1, v2)
  - MR1750 (v1, v2) [#ath10k]_
  - OM2P (v1, v2, v4)
  - OM2P-HS (v1, v2, v3, v4)
  - OM2P-LC
  - OM5P
  - OM5P-AN
  - OM5P-AC (v1, v2) [#ath10k]_

* TP-Link

  - Archer C5 (v1) [#ath10k]_
  - Archer C59 (v1) [#80211s]_
  - Archer C7 (v2, v4, v5) [#ath10k]_
  - CPE210 (v1.0, v1.1, v2.0)
  - CPE220 (v1.1)
  - CPE510 (v1.0, v1.1)
  - CPE520 (v1.1)
  - RE450 [#ath10k]_
  - TL-WDR3500 (v1)
  - TL-WDR3600 (v1)
  - TL-WDR4300 (v1)
  - TL-WR710N (v1, v2.1)
  - TL-WR810N (v1)
  - TL-WR842N/ND (v1, v2, v3)
  - TL-WR1043N/ND (v1, v2, v3, v4, v5)
  - TL-WR2543N/ND (v1)
  - WBS210 (v1.20)
  - WBS510 (v1.20)

* Ubiquiti

  - Air Gateway
  - Air Gateway LR
  - Air Gateway PRO
  - Air Router
  - Bullet M2/M5
  - Loco M2/M5
  - Loco M2/M5 XW
  - Nanostation M2/M5
  - Nanostation M2/M5 XW
  - Picostation M2
  - Rocket M2/M5
  - Rocket M2/M5 Ti
  - Rocket M2/M5 XW
  - UniFi AC Mesh [#ath10k]_
  - UniFi AC Mesh Pro [#ath10k]_
  - UniFi AP
  - UniFi AP AC Lite [#ath10k]_
  - UniFi AP AC LR [#ath10k]_
  - UniFi AP AC Pro [#ath10k]_
  - UniFi AP LR
  - UniFi AP Pro
  - UniFi AP Outdoor
  - UniFi AP Outdoor+

* Western Digital

  - My Net N600
  - My Net N750

* ZyXEL

  - NBG6616 [#ath10k]_

ar71xx-nand
^^^^^^^^^^^

* Netgear

  - WNDR3700 (v4)
  - WNDR4300 (v1)

* ZyXEL

  - NBG6716 [#ath10k]_

ar71xx-tiny
^^^^^^^^^^^

* D-Link

  - DIR-615 (C1)

* TP-Link

  - TL-MR13U (v1)
  - TL-MR3020 (v1)
  - TL-MR3040 (v1, v2)
  - TL-MR3220 (v1, v2)
  - TL-MR3420 (v1, v2)
  - TL-WA701N/ND (v1, v2)
  - TL-WA730RE (v1)
  - TL-WA750RE (v1)
  - TL-WA801N/ND (v1, v2, v3)
  - TL-WA830RE (v1, v2)
  - TL-WA850RE (v1)
  - TL-WA860RE (v1)
  - TL-WA901N/ND (v1, v2, v3, v4, v5)
  - TL-WA7210N (v2)
  - TL-WA7510N (v1)
  - TL-WR703N (v1)
  - TL-WR710N (v2)
  - TL-WR740N (v1, v3, v4, v5)
  - TL-WR741N/ND (v1, v2, v4, v5)
  - TL-WR743N/ND (v1, v2)
  - TL-WR841N/ND (v3, v5, v7, v8, v9, v10, v11, v12)
  - TL-WR843N/ND (v1)
  - TL-WR940N (v1, v2, v3, v4, v5, v6)
  - TL-WR941ND (v2, v3, v4, v5, v6)

brcm2708-bcm2708
^^^^^^^^^^^^^^^^

* RaspberryPi 1

brcm2708-bcm2709
^^^^^^^^^^^^^^^^

* RaspberryPi 2


ipq40xx
^^^^^^^

* AVM

  - FRITZ!Box 4040 [#80211s]_ [#avmflash]_

* GL.iNet

  - GL-B1300 [#80211s]_

* NETGEAR

  - EX6100v2 [#80211s]_
  - EX6150v2 [#80211s]_

* OpenMesh

  - A42 [#80211s]_
  - A62 [#80211s]_

* ZyXEL

  - NBG6617 [#80211s]_
  - WRE6606 [#80211s]_

ipq806x
^^^^^^^

* TP-Link

  - Archer C2600 [#80211s]_

mpc85xx-generic
^^^^^^^^^^^^^^^

* TP-Link

  - TL-WDR4900 (v1)

ramips-mt7620
^^^^^^^^^^^^^

* GL Innovations

  - GL-MT300A [#80211s]_
  - GL-MT300N [#80211s]_
  - GL-MT750 [#80211s]_

* Nexx

  - WT3020AD/F/H

ramips-mt7621
^^^^^^^^^^^^^

* D-Link

  - DIR-860L (B1) [#80211s]_

* Ubiquiti

  - EdgeRouter X
  - EdgeRouter X-SFP

* ZBT

  - WG3526-16M [#80211s]_
  - WG3526-32M [#80211s]_

ramips-mt76x8
^^^^^^^^^^^^^

* GL.iNet

  - GL-MT300N v2 [#80211s]_

* NETGEAR

  - R6120 [#80211s]_

* TP-Link

  - TL-WR841N v13 [#80211s]_
  - Archer C50 v3 [#80211s]_
  - Archer C50 v4 [#80211s]_

* VoCore

  - VoCore2 [#80211s]_

ramips-rt305x
^^^^^^^^^^^^^

* A5-V11 [#80211s]_

* D-Link

  - DIR-615 (D1, D2, D3, D4, H1) [#80211s]_

* VoCore

  - VoCore (8M, 16M) [#80211s]_

sunxi
^^^^^

* LeMaker

  - Banana Pi M1

x86-generic
^^^^^^^^^^^

* x86-generic
* x86-virtualbox
* x86-vmware

See also: :doc:`user/x86`

x86-geode
^^^^^^^^^

* x86-geode

See also: :doc:`user/x86`

x86-64
^^^^^^

* x86-64-generic
* x86-64-virtualbox
* x86-64-vmware

See also: :doc:`user/x86`

Footnotes
^^^^^^^^^

.. [#ath10k]
  Device uses the ath10k WLAN driver; images are built for 11s by default unless GLUON_WLAN_MESH
  is set as described in :ref:`getting-started-make-variables`

.. [#80211s]
  Device does not support IBSS; images are built by default unless GLUON_WLAN_MESH
  is explicitly set to something other than *11s*

.. [#avmflash]
  For instructions on how to flash AVM devices, visit https://fritzfla.sh

License
-------

See LICENCE_

.. _LICENCE: https://github.com/freifunk-gluon/gluon/blob/master/LICENSE

Indices and tables
==================

* :ref:`search`
