include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-filter-ra-dhcp

include ../gluon.mk

define Package/gluon-ebtables-filter-ra-dhcp
	TITLE:=Ebtables filters for Router Advertisement and DHCP packets
	DEPENDS:=+gluon-core +gluon-ebtables gluon-mesh-batman-adv
endef

define Package/gluon-ebtables-filter-ra-dhcp/description
	Gluon community wifi mesh firmware framework: Ebtables filters for Router Advertisement and DHCP packets

	These filters ensure that RA and DHCP packets are only forwarded from the mesh into the
	client network, and not vice-versa.
endef

$(eval $(call BuildPackageGluon,gluon-ebtables-filter-ra-dhcp))
