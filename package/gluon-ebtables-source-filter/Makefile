include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-source-filter

include ../gluon.mk

define Package/gluon-ebtables-source-filter
	TITLE:=Ebtables rules to filter unreasonable L2 traffic.
	DEPENDS:=+gluon-core +gluon-ebtables gluon-mesh-batman-adv
endef

define Package/gluon-ebtables-source-filter/description
	This package adds an additional layer-2 filter-ruleset to prevent unreasonable
	traffic entering the network via the nodes.
endef

$(eval $(call BuildPackageGluon,gluon-ebtables-source-filter))
