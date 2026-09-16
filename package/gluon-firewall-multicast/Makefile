include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall-multicast

include ../gluon.mk

define Package/gluon-firewall-multicast
  TITLE:=Multicast direction filter chains
  DEPENDS:=+gluon-core +gluon-firewall
endef

define Package/gluon-firewall-multicast/description
	Gluon community wifi mesh firmware framework: multicast filter chains

	Provides the MULTICAST_IN/MULTICAST_OUT filter chains that
	restrict multicast traffic between the mesh and the client
	network, and drops IGMP/MLD queries and (optionally) reports.
endef

$(eval $(call BuildPackageGluon,gluon-firewall-multicast))
