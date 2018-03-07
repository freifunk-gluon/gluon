include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alfred
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-alfred
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +gluon-respondd +gluon-neighbour-info gluon-mesh-batman-adv +micrond +alfred
  TITLE:=Configure alfred
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-alfred/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

$(eval $(call BuildPackage,gluon-alfred))
