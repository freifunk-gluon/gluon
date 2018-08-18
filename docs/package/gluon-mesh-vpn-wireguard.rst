gluon-mesh-vpn-wireguard
========================

This package allows WireGuard [1] to be used in Gluon. WireGuard establishes 
VPN connections on OSI layer 3 allowing increased throughput in comparison with 
fastd for mesh protocols that operate on layer 3 too.

When starting WireGuard, the system requires some entropy. It is recommended to 
use haveged to avoid long startup times.

[1] https://wireguard.io

site.conf
---------
This is similar to the fastd-based mesh_vpn structure.

Example::

  mesh_vpn = {
    mtu = 1374,
    wireguard = {
      enabled = true,
      groups = {
        backbone = {
          limit = 2,
          peers = {
            gw02 = {
              enabled = true,
              key = 'bog2DzyiC0Os7y1GloEw0afb8bLdZ9SzVQCd44Eock4=',
              remote = 'gw02.babel.ffm.freifunk.net',
              broker_port = 40000,
            },
          },
        },
      },
    },
  }

Server Side Configuration
-------------------------

* The wireguard private key must be deployed, and the derived Public Key has to be in site.conf
* The wg-broker-server script must be running on the server and be listening on
  the broker_port
* The node must be able to reach the server using TCP-Port broker_port and it
  must be able to communicate with the server using one UDP port between 40000
  and 41000.

On dockerhub there is an image klausdieter371/wg-docker integrating the
server-side components. Please refer to its documentation to set up the server
part. The Code and Documentation are kept here:
https://github.com/FreifunkMD/wg-docker

