Network Traffic
===============

In general, Freifunk does not filter network traffic. Users are not monitored.
But - Freifunk admins and those placing a router on
their premises have complete access to the hardware and all data passing
it. For the sake of transparency it should be explained how available the
users' data are to our volunteers.
Regular Internet Service Providers have the very same or better tools at their
disposal and many bored and/or curious staff at their disposal. End-to-end
cryptography sends only unreadable data packages.


Gateways - ours, those of our anonymisers, or of ISPs
-----------------------------------------------------

There are typically two or more gateways in a Freifunk network that collect traffic
from the WLAN routers and forward it to anonymisers, the gateway of other Freifunk communities, or
grant direct access to the Internet. A gateway is typically accessed via a regular
UNIX shell, and with so many different sites accessed by many individuals in
a network, any graphical separation of activities is difficult in the first place. 

*bandwith monitoring*

A tool with decent tabular and ASCII presentations is bmon. It ships as a cognate Debian
package:

        #   Interface                RX Rate         RX #     TX Rate         TX #
      ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
      gw2 (source: local)
        0   bat0                      36.83KiB        556       1.02MiB        762
        1   lo                         0.00B            0       0.00B            0
        2   dummy                      0.00B            0     493.00B            7
        3   ffoh-mesh-vpn             63.36KiB        797       1.07MiB       1516
        4   eth1                       0.00B            0       0.00B            0
        5   dummy0                     0.00B            0       0.00B            0
        6   eth0                       1.15MiB       1563       1.26MiB       2434
        7   mullvad                  288.52KiB        219      10.46KiB        152
      
      ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
      RX    KiB
         374.80 ...................................................*........
         312.33 .**................................................**.......
         249.87 ***................................................**.......
         187.40 ****...............................................**.......
         124.93 ****...*..........................................***.......
          62.47 ****:****::::::::::::::::::::::::::::::::::::::*::***::::::. [-0.01%]
                1   5   10   15   20   25   30   35   40   45   50   55   60 s
      TX    KiB
          30.64 ........*...................................................
          25.53 ........*..........................................*........
          20.43 .......**.......................................*..**.......
          15.32 .*.....**.................*....................**..**.......
          10.21 .*.*.****..........*......*....................******.......
           5.11 *************:.::::**:*****:****:**:***:*:::***********:*::. [-0.01%]
                1   5   10   15   20   25   30   35   40   45   50   55   60 s
      ────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
                            RX          TX    │                        RX          TX
       Bytes:             57.0 GiB     9.4 GiB│   Packets:       55655040    41097702
       Errors                0           0    │   Dropped               0           0
       FIFO Err              0           0    │   Frame Err             0           0
       Compressed            0           0    │   Multicast             0           0


In the above setup, about 90% of the traffic directly go to the Internet while a
remaining 10% of non-whitelisted traffic is routed through an anonymising service.
One gets a graphical impression of the fluctuations in the internet traffic. If
there is a hickup in the network for some router, starting bmon on the respective
gateway usually is informative.

*Forwarded connections*

The tool netstat characterises the traffic to and from the server.  But it gives no
further insight in what triggered a particular a particular forwarded connection.
The tool netstat-nat provides a respective resolution down to the IP address of the
client:

  # netstat-nat -Nx|head -10
  Proto NATed Address                            NAT-host Address                         Destination Address                      State
  icmp  10.135.21.25                             10.8.0.66                                s2.linuxsolutions.at
  tcp   10.135.11.209:35533                      gw2.ostholstein.freifunk.net:35533       217.118.169.213:http                     ESTABLISHED
  tcp   10.135.16.145:49413                      10.8.0.66:49413                          dub402-m.hotmail.com:https               ESTABLISHED
  tcp   10.135.16.145:49412                      10.8.0.66:49412                          bay405-m.hotmail.com:https               ESTABLISHED
  tcp   10.135.16.145:49153                      10.8.0.66:49153                          157.55.236.25:https                      ESTABLISHED
  tcp   10.135.16.146:61529                      gw2.ostholstein.freifunk.net:61529       17.130.16.4:https                        ESTABLISHED
  tcp   10.135.16.17:55309                       10.8.0.66:55309                          kundenserver.de:http                     ESTABLISHED
  tcp   10.135.16.177:53344                      gw2.ostholstein.freifunk.net:53344       yts10.yql.vip.bf1.yahoo.com:http         ESTABLISHED
  tcp   10.135.16.199:61262                      gw2.ostholstein.freifunk.net:61262       17.130.254.14:5223                       ESTABLISHED

The middle column identifies the gateway through which the connection is routed. The 10.8.0.66 is the anonymiser. 
The IP address 217.118.169.213 looks dubious at a first sight. The tool 'whois' identifies it as RTL, a TV station.  Netstat-nat
is available as a Debian package.

*See packages*

Every package passing the hardware can be inspected.  There is a batctl feature *tcpdump* to quickly
investigate the headers of packages.

  # batctl tcpdump -n bat0|head -n 10
  16:47:17.368968 IP 10.135.17.193.46028 > 158.85.58.105.443: TCP, flags [....A.], length 0
  16:47:17.380180 IP 198.136.45.174.38513 > 10.135.19.51.51061: TCP, flags [....A.], length 0
  16:47:17.386435 IP 54.230.130.71.80 > 10.135.21.14.33642: TCP, flags [...PA.], length 701
  16:47:17.406464 IP 10.135.19.51.51061 > 198.136.45.174.38513: TCP, flags [...PA.], length 86
  16:47:17.421005 ARP, Request who-has 10.135.22.111 tell 10.135.0.16 (ee:88:71:fa:40:cc), length 28
  16:47:17.421103 ARP, Reply 10.135.22.111 is-at 40:f3:08:74:0d:69, length 28
  16:47:17.430465 IP 212.11.63.254.80 > 10.135.21.14.56605: TCP, flags [....A.], length 416
  16:47:17.430531 IP 212.11.63.254.80 > 10.135.21.14.56605: TCP, flags [...PA.], length 1145
  16:47:17.430548 IP 212.11.63.254.80 > 10.135.21.14.56605: TCP, flags [....A.], length 1356
  16:47:17.430561 IP 212.11.63.254.80 > 10.135.21.14.56605: TCP, flags [...PA.], length 104

The original tool provides about the same kind of output and is particularly prepared for the
use of filters, i.e. a logical expression to indicate the packages that should be selected for
display / the writing to a file.

The tcpdump can be combined with a grep to learn about the activity of an individual
client (or a trojan on that client).

  # tcpdump -i bat0 
  tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
  listening on bat0, link-type EN10MB (Ethernet), capture size 65535 bytes
  16:50:59.604815 IP 10.135.20.80.52196 > 17.173.66.104.https: Flags [P.], seq 3365924598:3365925147, ack 1754814341, win 8192, length 549
  16:50:59.608324 IP 10.135.20.211.57280 > ec2-50-16-207-102.compute-1.amazonaws.com.https: Flags [.], ack 1426811095, win 1234, options [nop,nop,TS val 18402430 ecr 36686067], length 0
  16:50:59.608448 IP 10.135.20.80.52198 > 62.146.20.212.https: Flags [P.], seq 1451618102:1451618177, ack 2182802755, win 4096, options [nop,nop,TS val 537078044 ecr 523476758], length 75
  16:50:59.610983 IP 10.135.20.80.52198 > 62.146.20.212.https: Flags [P.], seq 75:81, ack 1, win 4096, options [nop,nop,TS val 537078044 ecr 523476758], length 6
  16:50:59.613335 IP 10.135.19.58.50816 > asa-glx-gsg004.gameloft.com.38513: Flags [.], ack 243153572, win 1455, options [nop,nop,TS val 8404145 ecr 71236049], length 0
  16:50:59.614951 IP 10.135.20.80.52198 > 62.146.20.212.https: Flags [P.], seq 81:166, ack 1, win 4096, options [nop,nop,TS val 537078044 ecr 523476758], length 85
  16:50:59.616287 IP 10.135.20.211.57280 > ec2-50-16-207-102.compute-1.amazonaws.com.https: Flags [.], ack 1357, win 1234, options [nop,nop,TS val 18402431 ecr 36686069], length 0
  16:50:59.617139 IP ec2-50-16-207-102.compute-1.amazonaws.com.https > 10.135.20.211.57280: Flags [.], seq 1357:2713, ack 0, win 70, options [nop,nop,TS val 36686076 ecr 18402414], length 1356
  16:50:59.617219 IP ec2-50-16-207-102.compute-1.amazonaws.com.https > 10.135.20.211.57280: Flags [.], seq 2713:4069, ack 0, win 70, options [nop,nop,TS val 36686076 ecr 18402414], length 1356

The 'port 80' below is an example for a filter - which is the non-encrypted web page transfer.
The data is read from a file that was created with tcpdump -w somefile before. The -X shows 
the data transported with the page, i.e. the web page itself.

    # tcpdump -r somefile -X port 80
    17:25:55.411142 IP lhr08s05-in-f3.1e100.net.http > 10.135.20.207.45588: Flags [P.], seq 1:1140, ack 168, win 341, options [nop,nop,TS val 1928209820 ecr 30724122], length 1139
   ...
            0x0380:  436f 6e6e 6563 7469 6f6e 3a20 636c 6f73  Connection:.clos
            0x0390:  650d 0a0d 0a3c 4854 4d4c 3e3c 4845 4144  e....<HTML><HEAD
            0x03a0:  3e3c 6d65 7461 2068 7474 702d 6571 7569  ><meta.http-equi
            0x03b0:  763d 2263 6f6e 7465 6e74 2d74 7970 6522  v="content-type"
            0x03c0:  2063 6f6e 7465 6e74 3d22 7465 7874 2f68  .content="text/h
            0x03d0:  746d 6c3b 6368 6172 7365 743d 7574 662d  tml;charset=utf-
            0x03e0:  3822 3e0a 3c54 4954 4c45 3e33 3032 204d  8">.<TITLE>302.M
            0x03f0:  6f76 6564 3c2f 5449 544c 453e 3c2f 4845  oved</TITLE></HE
            0x0400:  4144 3e3c 424f 4459 3e0a 3c48 313e 3330  AD><BODY>.<H1>30
            0x0410:  3220 4d6f 7665 643c 2f48 313e 0a54 6865  2.Moved</H1>.The
            0x0420:  2064 6f63 756d 656e 7420 6861 7320 6d6f  .document.has.mo
    ...
            0x0490:  3c2f 413e 2e0d 0a3c 2f42 4f44 593e 3c2f  </A>...</BODY></
            0x04a0:  4854 4d4c 3e0d 0a                        HTML>..


WLAN Routers 
------------

to be written

Clients
-------

*WLAN sniffers*

to be written
