Welcome to Gluon
================

Gluon is a modular framework for creating OpenWrt-based firmwares for wireless mesh nodes.
Several Freifunk communities in Germany use Gluon as the foundation of their Freifunk firmwares.


User Documentation
------------------

.. toctree::
   :maxdepth: 2

   user/getting_started
   user/site
   user/x86
   user/faq

Features
--------

.. toctree::
   :maxdepth: 2

   features/configmode
   features/autoupdater
   features/wlan-configuration
   features/private-wlan
   features/wired-mesh
   features/monitoring
   features/authorized-keys
   features/roles

Developer Documentation
-----------------------

.. toctree::
   :maxdepth: 2

   dev/basics
   dev/hardware
   dev/upgrade
   dev/configmode
   dev/wan
   dev/i18n
   dev/mac_addresses

Packages
--------

.. toctree::
   :maxdepth: 1

   package/gluon-client-bridge
   package/gluon-config-mode-contact-info
   package/gluon-config-mode-geo-location
   package/gluon-ebtables-filter-multicast
   package/gluon-ebtables-filter-ra-dhcp
   package/gluon-ebtables-segment-mld

Releases
--------

.. toctree::
   :maxdepth: 1

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
  - AP121U
  - Hornet-UB
  - Tube2H
  - N2
  - N5

* Allnet

  - ALL0315N

* Buffalo

  - WZR-HP-AG300H / WZR-600DHP
  - WZR-HP-G300NH
  - WZR-HP-G300NH2
  - WZR-HP-G450H

* Cisco Meraki

  - MR12 / MR62
  - MR16 / MR66

* D-Link

  - DIR-505 (A1, A2)
  - DIR-615 (C1)
  - DIR-825 (B1)

* GL Innovations

  - GL-AR150
  - GL-iNet 6408A (v1)
  - GL-iNet 6416A (v1)

* Linksys

  - WRT160NL

* Netgear

  - WNDR3700 (v1, v2)
  - WNDR3800
  - WNDRMAC (v2)

* Onion

  - Omega

* OpenMesh

  - MR600 (v1, v2)
  - MR900 (v1, v2)
  - MR1750 (v1, v2) [#ath10k]_
  - OM2P (v1, v2)
  - OM2P-HS (v1, v2, v3)
  - OM2P-LC
  - OM5P
  - OM5P-AN
  - OM5P-AC (v1, v2) [#ath10k]_

* TP-Link

  - Archer C5 (v1) [#ath10k]_
  - Archer C7 (v2) [#ath10k]_
  - CPE210 (v1.0, v1.1)
  - CPE220 (v1.0, v1.1)
  - CPE510 (v1.0, v1.1)
  - CPE520 (v1.0, v1.1)
  - TL-MR13U (v1)
  - TL-MR3020 (v1)
  - TL-MR3040 (v1, v2)
  - TL-MR3220 (v1, v2)
  - TL-MR3420 (v1, v2)
  - TL-WA701N/ND (v1, v2)
  - TL-WA750RE (v1)
  - TL-WA7510N (v1)
  - TL-WA801N/ND (v1, v2, v3)
  - TL-WA830RE (v1, v2)
  - TL-WA850RE (v1)
  - TL-WA860RE (v1)
  - TL-WA901N/ND (v1, v2, v3, v4)
  - TL-WDR3500 (v1)
  - TL-WDR3600 (v1)
  - TL-WDR4300 (v1)
  - TL-WR703N (v1)
  - TL-WR710N (v1, v2, v2.1)
  - TL-WR740N (v1, v3, v4, v5)
  - TL-WR741N/ND (v1, v2, v4, v5)
  - TL-WR743N/ND (v1, v2)
  - TL-WR801N/ND (v1, v2)
  - TL-WR841N/ND (v3, v5, v7, v8, v9, v10, v11)
  - TL-WR842N/ND (v1, v2, v3)
  - TL-WR843N/ND (v1)
  - TL-WR940N (v1, v2, v3, v4)
  - TL-WR941ND (v2, v3, v4, v5, v6)
  - TL-WR1043N/ND (v1, v2, v3, v4)
  - TL-WR2543N/ND (v1)

* Ubiquiti

  - Air Gateway
  - Air Router
  - Bullet M2/M5
  - Loco M2/M5
  - Loco M2/M5 XW
  - Nanostation M2/M5
  - Nanostation M2/M5 XW
  - Picostation M2/M5
  - Rocket M2/M5
  - Rocket M2/M5 XW
  - UniFi AP
  - UniFi AP AC Lite [#ath10k]_
  - UniFi AP AC Pro [#ath10k]_
  - UniFi AP Pro
  - UniFi AP Outdoor
  - UniFi AP Outdoor+

* Western Digital

  - My Net N600
  - My Net N750

.. [#ath10k]
  Device uses the ath10k WLAN driver; no image is built unless GLUON_ATH10K_MESH
  is set as described in :ref:`getting-started-make-variables`

ar71xx-nand
^^^^^^^^^^^

* Netgear

  - WNDR3700 (v4)
  - WNDR4300 (v1)

brcm2708-bcm2708
^^^^^^^^^^^^^^^^

* RaspberryPi 1

brcm2708-bcm2709
^^^^^^^^^^^^^^^^

* RaspberryPi 2

mpc85xx-generic
^^^^^^^^^^^^^^^

* TP-Link

  - TL-WDR4900 (v1)

x86-generic
^^^^^^^^^^^

* x86-generic
* x86-virtualbox
* x86-vmware

See also: :doc:`user/x86`

x86-kvm_guest
^^^^^^^^^^^^^

* x86-kvm

See also: :doc:`user/x86`

x86-xen_domu
^^^^^^^^^^^^

* x86-xen

See also: :doc:`user/x86`

x86-64
^^^^^^

* x86-64-generic
* x86-64-virtualbox
* x86-64-vmware

See also: :doc:`user/x86`

License
-------

See LICENCE_

.. _LICENCE: https://github.com/freifunk-gluon/gluon/blob/master/LICENSE

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
