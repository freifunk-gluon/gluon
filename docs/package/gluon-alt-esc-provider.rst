gluon-alt-esc-provider
======================

The *gluon-alt-esc-provider* package is the counterpart to the *gluon-alt-esc-client*
package. It configures the firewall of the according Gluon node to grant permission
to route packets between the client (mesh clients) and wan zone (private network
behind the WAN port).

Packets from the client to the wan zone are NAT'ed both for IPv4 and IPv6.

Two notes: Beware of the security implications for routers and hosts in your wan
zone (yes, your 192.168.x.x devices will be accessible from the mesh).

Secondly, note that the Gluon Alt-ESC provider package is not mandatory for the
Gluon Alt-ESC client package. In fact, any client device in the mesh network
can be chosen and configured to provide internet access for the Alt-ESC
client package.
