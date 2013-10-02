include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-location
PKG_VERSION:=1
PKG_location:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-location
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Add system.location to uci
  DEPENDS:=+gluon-core
endef

define Package/gluon-location/description
	This packages creates /lib/gluon/location.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-location/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-location))
