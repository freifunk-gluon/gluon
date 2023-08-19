include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-nftables-source-filter

include ../gluon.mk

define Package/gluon-nftables-source-filter
  TITLE:=nftables rules to filter unreasonable L2 traffic.
  DEPENDS:=+gluon-core +gluon-nftables +gluon-mesh-batman-adv
endef

define Package/gluon-nftables-source-filter/description
	This package adds an additional layer-2 filter-ruleset to prevent unreasonable
	traffic entering the network via the nodes.
endef

$(eval $(call BuildPackageGluon,gluon-nftables-source-filter))
