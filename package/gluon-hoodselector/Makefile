include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-hoodselector

GLUON_VERSION:=3
PKG_VERSION:=2

include ../gluon.mk

define Package/gluon-hoodselector
  TITLE:=Automatically sortes nodes into network domains.
  DEPENDS:=+luaposix +libgluonutil +lua-math-polygon +libjson-c +gluon-site +micrond +luabitop @GLUON_MULTIDOMAIN
  CONFLICTS:=+gluon-config-mode-domain-select
endef

define Package/gluon-hoodselector/description
  The job of the hoodselector is to automatically detect in which domain
  the node is located based on geo settings. Based on this information
  the hoodselector will select a domain from a list of known domains
  and adjust the domain related settings e.g. VPN, wireless ...
endef

$(eval $(call BuildPackageGluon,gluon-hoodselector))
