include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-client-isolation

include ../gluon.mk

define Package/gluon-client-isolation
  TITLE:=Support for client isolation over batman-adv
  DEPENDS:=+gluon-core +gluon-ebtables gluon-mesh-batman-adv
endef

define Package/gluon-client-isolation/description
	This package provides client isolation in a batman-adv
	bridged layer 2 network.

	To use it, mesh.isolate must be set in the site or
	domain configuration.

	When it is set to wireless, wireless clients are isolated from
	other wireless clients, wireless to wired, wired to wireless
	and wire to wired traffic is not affected in this mode.

	When it is set to all, wired traffic is also isolated.

	To isolate the clients connected to the same wireless interface,
	it sets the isolate option in the wireless configuration for
	the client and owe wifi interfaces.

	To extend the isolation the ap_isolation and isolation_mark
	options are set for the gluon_bat0 network interface.

	A new filter chain ISOLATED is added to ebtables, through which
	all traffic of br-client is routed.
	Depending the value of mesh.isolate, the traffic is marked when
	it arrives from the interfaces to isolate and batman-adv
	restores the mark for isolated traffic from other nodes.
	The marked traffic will not be forwarded to isolated interfaces.
endef

$(eval $(call BuildPackageGluon,gluon-client-isolation))
