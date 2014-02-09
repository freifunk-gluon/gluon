# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-core
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-luci-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci code shared by configmode and expertmode
  DEPENDS:=+gluon-core +gluon-luci-theme +luci-lib-web
endef

define Package/gluon-luci-core/description
	Luci code shared by various gluon packages
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-luci-core/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-luci-core))
