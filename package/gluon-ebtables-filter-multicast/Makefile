include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-filter-multicast

include ../gluon.mk

define Package/gluon-ebtables-filter-multicast
  TITLE:=Ebtables filters for multicast packets
  DEPENDS:=+gluon-core +gluon-ebtables gluon-mesh-batman-adv
endef

define Package/gluon-ebtables-filter-multicast/description
	Gluon community wifi mesh firmware framework: Ebtables filters for multicast packets

	These filters drop non-essential multicast traffic before it enters the mesh.

	Allowed protocols are: DHCP, DHCPv6, ARP, ICMP, ICMPv6, BitTorrent local peer discovery, BABEL and OSPF
endef

$(eval $(call BuildPackageGluon,gluon-ebtables-filter-multicast))
