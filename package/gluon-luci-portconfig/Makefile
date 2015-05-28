# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-portconfig
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-luci-portconfig
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci module for advanced ethernet port configuration
  DEPENDS:=+gluon-luci-admin +gluon-mesh-batman-adv
endef

define Package/gluon-luci-portconfig/description
	Luci module for advanced ethernet port configuration
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-luci-portconfig/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-luci-portconfig))
