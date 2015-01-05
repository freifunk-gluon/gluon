.. _accessing-nodes:

Accessing running nodes
=======================

Routers all have IPv6 addresses and within our batman network are treated like regular
computers - they are regular computers with a built-in WLAN device. One we know the
IPv6 address, one can access the device - to initiate a firmware update, perform
various sorts of maintenance for customised setups, or to just learn what is going on
when a node does not perform as expected.

'Access' may mean a mere ping/traceroute to determine if a site can be reached.
To truly enter a machine, one will use ssh and the machines need to be prepared
for it with a password or a public key as explained below. Telnet access is only
possible when booting into safe-mode - which is explained elsewhere.

Adding a password
-----------------

To set a password for any user of the routers, especially so for root, is not encouraged.
It comes handy, though, especially when loggin in from a machine that does not have your
private (secret) SSH key, e.g. from a gateway machine, but the very same is also its
disadvantage.

To set a password the regular configuration screen with lua may already allow
specifying it. If that was disabled for security reasons, please
 * boot into safe-mode
 * telnet the router on 192.168.1.1
 * on the device
     mount_root
     passwd
SSH login will be possible after the start of dropbear, which is regularly performed
when running in normal mode. For users other than root, please perform as with any Linux
machine.

.. seealso::

    For Information how to add SSH public Keys see :ref:`add-ssh-keys`.

How to find the IPv6 address of a router of interest
----------------------------------------------------

The IPv6 addresses of the routers are static and derived from
the MAC adresses. Consequently, one needs to determine the IPv6
address only once per device.

To find the IPv6 address one can
 * look at the bottom of the device and find a MAC address
 * know the IPv4 number of a mobile client accessing the network through that device and perform
   batctl traceroute on the IPv4 address assigned to that device. The last hub is the MAC address:
     # batctl traceroute 10.135.17.193
     traceroute to 10.135.17.193 (26:a4:3c:f0:b5:0a), 50 hops max, 20 byte packets
     1: 12:fe:ed:3b:3f:cb  22.418 ms  23.008 ms  24.980 ms
     2: 26:a4:3c:f0:b5:0a  28.733 ms  26.018 ms  22.403 ms
 * There are rules for an automated transcription of MAC addresses to IPv6 addresses,
   automated e.g. at http://ben.akrin.com/?p=1347 - it is basically an insertion of ff:ef in the
   middle and fe80:: as a prefix.
 * check response times - the routers answering first are the ones connected the query host
    # ping6 -I bat0 ff02::2 | head -n 5
    PING ff02::2(ff02::2) from fe80::ec88:71ff:fefa:40cc bat0: 56 data bytes
    64 bytes from fe80::ec88:71ff:fefa:40cc: icmp_seq=1 ttl=64 time=0.066 ms
    64 bytes from fe80::c24a:ff:fe42:2120: icmp_seq=1 ttl=255 time=26.6 ms (DUP!)
    64 bytes from fe80::fa1a:67ff:fe31:69ca: icmp_seq=1 ttl=255 time=27.1 ms (DUP!)
    64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=1 ttl=255 time=27.5 ms (DUP!)
   These addresses are local-link IPv6 addresses and can be contacted directly.
 * It is expected these MAC addresses not to be exactly the same as the ones seen underneath
   the device, since WLAN and Ethernet are different devices, and only the MAC addresses
   of either are depicted, and there may be different MAC addreses for the WAN and LAN ports.


Contacting the device
---------------------

For a mere ping, perform
  # ping6 -I bat0 fe80::12fe:edff:feaf:57cc
  PING fe80::12fe:edff:feaf:57cc(fe80::12fe:edff:feaf:57cc) from fe80::ec88:71ff:fefa:40cc bat0: 56 data bytes
  64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=1 ttl=64 time=54.2 ms
  64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=2 ttl=64 time=28.3 ms
i.e. use ping6 instead of IPv4 ping and help with the interface.

For SSH, analogously do
  # ssh fe80::12fe:edff:feaf:57cc%bat0
  The authenticity of host 'fe80::12fe:edff:feaf:57cc%bat0 (fe80::12fe:edff:feaf:57cc%bat0)' can't be established.
  RSA key fingerprint is 53:5c:ac:f8:65:74:0b:cb:a4:67:26:3a:f5:65:2f:77.
  Are you sure you want to continue connecting (yes/no)?


