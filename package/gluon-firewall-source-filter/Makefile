include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall-source-filter

include ../gluon.mk

define Package/gluon-firewall-source-filter
  TITLE:=Ebtables rules to filter unreasonable L2 traffic.
  DEPENDS:=+gluon-core +gluon-firewall gluon-mesh-batman-adv
endef

define Package/gluon-firewall-source-filter/description
	This package adds an additional layer-2 filter-ruleset to prevent unreasonable
	traffic entering the network via the nodes.
endef

$(eval $(call BuildPackageGluon,gluon-firewall-source-filter))
