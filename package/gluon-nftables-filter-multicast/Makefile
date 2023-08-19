include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-nftables-filter-multicast

include ../gluon.mk

define Package/gluon-nftables-filter-multicast
  TITLE:=nftables filters for multicast packets
  DEPENDS:=+gluon-core +gluon-nftables +gluon-nftables-multicast +gluon-mesh-batman-adv
endef

define Package/gluon-nftables-filter-multicast/description
	Gluon community wifi mesh firmware framework: nftables filters for multicast packets

	These filters drop non-essential multicast traffic before it enters the mesh.

	Allowed protocols are: DHCP, DHCPv6, ARP, ICMP, ICMPv6, BitTorrent local peer discovery, BABEL and OSPF
endef

$(eval $(call BuildPackageGluon,gluon-nftables-filter-multicast))
