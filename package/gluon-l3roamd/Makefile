include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-l3roamd
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

define Package/gluon-l3roamd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Configure l3roamd for babel
  DEPENDS:=+gluon-core +gluon-mesh-babel +l3roamd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-l3roamd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

$(eval $(call BuildPackage,gluon-l3roamd))
