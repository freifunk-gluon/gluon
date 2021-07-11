Supported Devices & Architectures
=================================

ath79-generic
--------------

* devolo

  - WiFi pro 1200e [#lan_as_wan]_
  - WiFi pro 1200i
  - WiFi pro 1750c
  - WiFi pro 1750e [#lan_as_wan]_
  - WiFi pro 1750i
  - WiFi pro 1750x

* GL.iNet

  - GL-AR300M-Lite

* OCEDO

  - Raccoon

* Plasma Cloud

  - PA300
  - PA300E

* Siemens

  - WS-AP3610

* TP-Link

  - Archer C6 (v2)
  - CPE220 (v3.0)

ath79-nand
----------

* GL.iNet

  - GL-AR750S

brcm2708-bcm2708
----------------

* RaspberryPi 1

brcm2708-bcm2709
----------------

* RaspberryPi 2


ipq40xx-generic
---------------

* Aruba

  - AP-303
  - Instant On AP11

* AVM

  - FRITZ!Box 4040 [#avmflash]_
  - FRITZ!Box 7530 [#eva_ramboot]_
  - FRITZ!Repeater 1200 [#eva_ramboot]_

* EnGenius

  - ENS620EXT

* GL.iNet

  - GL-B1300

* Linksys

  - EA6350 (v3)

* NETGEAR

  - EX6100 (v2)
  - EX6150 (v2)

* OpenMesh

  - A42
  - A62

* Plasma Cloud

  - PA1200
  - PA2200

* ZyXEL

  - NBG6617
  - WRE6606  [#device-class-tiny]_

ipq806x-generic
---------------

* NETGEAR

  - R7800

lantiq-xrx200
-------------

* AVM

  - FRITZ!Box 7360 (v1, v2) [#avmflash]_ [#lan_as_wan]_
  - FRITZ!Box 7360 SL [#avmflash]_ [#lan_as_wan]_
  - FRITZ!Box 7362 SL [#eva_ramboot]_ [#lan_as_wan]_
  - FRITZ!Box 7412 [#eva_ramboot]_

lantiq-xway
-----------

* AVM

  - FRITZ!Box 7312 [#avmflash]_

* NETGEAR

  - DGN3500B [#lan_as_wan]_

mediatek-mt7622
---------------

* Ubiquiti

  - UniFi 6 LR

mpc85xx-generic
---------------

* TP-Link

  - TL-WDR4900 (v1)

mpc85xx-p1020
---------------

* Aerohive

  - HiveAP 330

* Enterasys

  - WS-AP3710i

* OCEDO

  - Panda

ramips-mt7620
-------------

* GL.iNet

  - GL-MT300A
  - GL-MT300N
  - GL-MT750

* NETGEAR

  - EX3700
  - EX3800

* Nexx

  - WT3020AD/F/H

* TP-Link

  - Archer C2 (v1)
  - Archer C20 (v1)
  - Archer C20i
  - Archer C50 (v1)

* Xiaomi

  - MiWiFi Mini

ramips-mt7621
-------------

* ASUS

  - RT-AC57U

* D-Link

  - DIR-860L (B1)

* NETGEAR

  - EX6150 (v1)
  - R6220

* Ubiquiti

  - EdgeRouter X
  - EdgeRouter X-SFP

* ZBT

  - WG3526-16M
  - WG3526-32M
  
* Xiaomi

  - Xiaomi Mi Router 4A (Gigabit Edition)

ramips-mt76x8
-------------

* Cudy

  - WR1000 (v1)

* GL.iNet

  - GL-MT300N (v2)
  - VIXMINI

* NETGEAR

  - R6120

* TP-Link

  - Archer C50 (v3)
  - Archer C50 (v4)
  - TL-MR3020 (v3)
  - TL-MR3420 (v5)
  - TL-WA801ND (v5)
  - TL-WR841N (v13)
  - TL-WR902AC (v3)

* VoCore

  - VoCore2

* Xiaomi

  - Xiaomi Mi Router 4A (100M Edition)
  - Xiaomi Mi Router 4C

rockchip-armv8
--------------

* FriendlyElec

  - NanoPi R2S

sunxi-cortexa7
--------------

* LeMaker

  - Banana Pi M1

x86-generic
-----------

* x86-generic
* x86-virtualbox
* x86-vmware

See also: :doc:`x86`

x86-geode
---------

* x86-geode

See also: :doc:`x86`

x86-64
------

* x86-64-generic
* x86-64-virtualbox
* x86-64-vmware

See also: :doc:`x86`

Footnotes
---------

.. [#device-class-tiny]
  These devices only support a subset of Gluons capabilities due to flash or memory
  size constraints. Devices are classified as tiny in they provide less than 7M of usable
  flash space or have a low amount of system memory. For more information, see the
  developer documentation: :ref:`device-class-definition`.

.. [#avmflash]
  For instructions on how to flash AVM devices, visit https://fritzfla.sh

.. [#eva_ramboot]
  For instructions on how to flash AVM NAND devices, see the respective
  commit which added support in OpenWrt.

.. [#lan_as_wan]
  All LAN ports on this device are used as WAN.
