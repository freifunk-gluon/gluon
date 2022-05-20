# ffgraz-mesh-olsr12-openvpn

This package is used to allow a seamless olsr2 migration
in an existing olsr1 mesh,
by connecting to a shared openvpn server that is reachable from
the olsr1 mesh.

Technical presentation (german): https://docs.google.com/presentation/d/1IPWPsQH3fNRfGLB4s2G2gFVltrFcg6gDKNvkcgMcsvA/edit#slide=id.g122e82f6b82_0_50

Configuration for site.conf

```
{
  mesh = {
    olsrd = {
      -- ...
      olsr12 = {
        enable = true,
        server = 'OLSR-IP',
        ca = [[
paste openvpn ca here
        ]],
      },
      -- ....
    },
  },
```

OpenVPN server

```
local OLSR-IP
port 1194
proto udp

dev olsr12
dev-type tap
server 10.8.0.0 255.255.255.0

keepalive 10 120

persist-key
persist-tun

verify-client-cert none
username-as-common-name
script-security 3
auth-user-pass-verify /bin/true via-env

status /var/log/olsr12-openvpn-status.log
log-append /var/log/olsr12-openvpn.log

data-ciphers-fallback none
dh none

ca /var/olsr12.ca.crt
cert /var/olsr12.crt
key /var/olsr12.key

verb 3
explicit-exit-notify 1
```
