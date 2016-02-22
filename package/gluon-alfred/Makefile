include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alfred
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-alfred
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +gluon-respondd +gluon-neighbour-info +micrond +alfred
  TITLE:=Configure alfred
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-alfred/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-alfred))
