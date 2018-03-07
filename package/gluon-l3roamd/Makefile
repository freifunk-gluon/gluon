include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-l3roamd
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-l3roamd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Configure l3roamd for babel
  DEPENDS:=+gluon-core +l3roamd
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-l3roamd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

$(eval $(call BuildPackage,gluon-l3roamd))
