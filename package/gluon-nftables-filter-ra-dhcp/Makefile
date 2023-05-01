include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-nftables-filter-ra-dhcp

include ../gluon.mk

define Package/gluon-nftables-filter-ra-dhcp
  TITLE:=nftables filters for Router Advertisement and DHCP packets
  DEPENDS:=+gluon-core +gluon-nftables +gluon-mesh-batman-adv
endef

define Package/gluon-nftables-filter-ra-dhcp/description
	Gluon community wifi mesh firmware framework: nftables filters for Router Advertisement and DHCP packets

	These filters ensure that RA and DHCP packets are only forwarded from the mesh into the
	client network, and not vice-versa.
endef

$(eval $(call BuildPackageGluon,gluon-nftables-filter-ra-dhcp))
