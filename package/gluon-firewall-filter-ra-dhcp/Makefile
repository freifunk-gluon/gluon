include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall-filter-ra-dhcp

include ../gluon.mk

define Package/gluon-firewall-filter-ra-dhcp
  TITLE:=Ebtables filters for Router Advertisement and DHCP packets
  DEPENDS:=+gluon-core +gluon-firewall-multicast gluon-mesh-batman-adv
endef

define Package/gluon-firewall-filter-ra-dhcp/description
	Gluon community wifi mesh firmware framework: Ebtables filters for Router Advertisement and DHCP packets

	These filters ensure that RA and DHCP packets are only forwarded from the mesh into the
	client network, and not vice-versa.
endef

$(eval $(call BuildPackageGluon,gluon-firewall-filter-ra-dhcp))
