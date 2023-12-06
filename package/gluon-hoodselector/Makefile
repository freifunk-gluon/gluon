include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-hoodselector

include ../gluon.mk

define Package/gluon-hoodselector
  TITLE:=Automatically migrate nodes between domains.
  DEPENDS:=+luaposix +libgluonutil +lua-math-polygon +libjson-c +gluon-site +micrond +lua-bit32 @GLUON_MULTIDOMAIN
  CONFLICTS:=+gluon-config-mode-domain-select
endef

define Package/gluon-hoodselector/description
  Hoodselector automatically detects in which domain the node is
  located based on its geolocation settings. Domains require
  bounding boxes defined as polygons or rectangles. Hoodselector
  selects a domain from the list of known domains and migrate
  towards it without requiring a reboot.
endef

$(eval $(call BuildPackageGluon,gluon-hoodselector))
