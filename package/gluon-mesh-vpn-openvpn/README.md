# ffgraz-mesh-vpn-openvpn

OpenVPN Mesh VPN support

# configuration

site.conf

```
{
  mesh_vpn = {
    openvpn = {
      enabled = true,
      mtu = 1312,
      -- Whether to auto-generate self-signed certificate if none found (default: true)
      self_signed = true,
      ca = [[
PASTE CA HERE
      ]],
      config = {
        remote = {
          'your-server.com 1194'
        },
        ca = '/etc/openvpn/ca.pem',
        cert = '/etc/openvpn/cert.pem',
        key = '/etc/openvpn/key.pem',
        -- additional options...
      }
    }
  }
}
```
