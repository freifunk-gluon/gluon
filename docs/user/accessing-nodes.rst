Accessing running nodes
=======================

Within the mesh network all nodes have IPv6 addresses and are treated like regular
computers - with a built-in WLAN device. Once we know their IPv6 address,  the device
can be accessed. There are various motivations to access a router, e.g. to initiate
a firmware update, perform  maintenance for customized setups, to investigate when
a node is not working as expected, to access data from
an external storage deviced, or tap into a sensor network attached to it, and be
it a mere web camera. 

**Access** in its simplest form may mean a mere ``ping``/``traceroute`` to determine if a host can be reached.
To truly enter a machine, one will use SSH. See :doc:`/user/authentication` for information
how to set it up.

How to find the IPv6 address of a desired node
----------------------------------------------

The IPv6 addresses of the nodes are static and may be derived from their MAC addresses.
Consequently, one needs to determine the IPv6 address only once per device.

To find the IPv6 address one can

*   Determine the IPv6 address via the device's MAC address.

    There are rules for an automated transcription of MAC addresses into IPv6
    addresses. You can find an a web service  at `ben.akrin.com <http://ben.akrin.com/?p=1347>`_.
    The procedure is basically an insertion of ``ff:ef`` in the middle, some bit
    swapping and adding ``fe80::`` as prefix.
    
    To find this physical network address:

   *   Look at the bottom of the device and find a label with the MAC address there.
   
   *   You can find a node address if you know the IPv4 address of a client connected
       to it. If you perform a ``batctl traceroute`` to that client from any other Node
       in the mesh, the MAC address can be found in the last hub::

            $ batctl traceroute 10.135.17.193

            traceroute to 10.135.17.193 (26:a4:3c:f0:b5:0a), 50 hops max, 20 byte packets
            1: 12:fe:ed:3b:3f:cb  22.418 ms  23.008 ms  24.980 ms
            2: 26:a4:3c:f0:b5:0a  28.733 ms  26.018 ms  22.403 ms
            
*   Directly connect via LAN-Cable and use the **next_node** addresses (if configured).

*   Check response times - the nodes answering first are those connected directly
    to the querying host::

            $ ping6 -I bat0 ff02::2 | head -n 5

            PING ff02::2(ff02::2) from fe80::ec88:71ff:fefa:40cc bat0: 56 data bytes
            64 bytes from fe80::ec88:71ff:fefa:40cc: icmp_seq=1 ttl=64 time=0.066 ms
            64 bytes from fe80::c24a:ff:fe42:2120: icmp_seq=1 ttl=255 time=26.6 ms (DUP!)
            64 bytes from fe80::fa1a:67ff:fe31:69ca: icmp_seq=1 ttl=255 time=27.1 ms (DUP!)
            64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=1 ttl=255 time=27.5 ms (DUP!)

    These addresses are local-link IPv6 addresses and can be contacted directly.

.. note::
        WLAN and Ethernet are different network devices, each with it's own MAC address,
        albeit wired up to the same machine.

        These two MAC addresses are commonly not identical. Expect to find only one
        of the two devices mentioned on a label. Worse - for the same device, its
        reported MAC address may depend on if it is meshing via its WLAN device or
        if it is contacting via VPN directly.

Contacting the device
---------------------

For a mere ping, perform::

    $ ping6 -I bat0 fe80::12fe:edff:feaf:57cc

    PING fe80::12fe:edff:feaf:57cc(fe80::12fe:edff:feaf:57cc) from fe80::ec88:71ff:fefa:40cc bat0: 56 data bytes
    64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=1 ttl=64 time=54.2 ms
    64 bytes from fe80::12fe:edff:feaf:57cc: icmp_seq=2 ttl=64 time=28.3 ms

i.e. use ping6 instead of IPv4 ping and help with the interface.

For SSH, analogously do::

      $ ssh fe80::12fe:edff:feaf:57cc%bat0

      The authenticity of host 'fe80::12fe:edff:feaf:57cc%bat0 (fe80::12fe:edff:feaf:57cc%bat0)' can't be established.
      RSA key fingerprint is 53:5c:ac:f8:65:74:0b:cb:a4:67:26:3a:f5:65:2f:77.
      Are you sure you want to continue connecting (yes/no)?

