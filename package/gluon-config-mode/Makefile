# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode
PKG_VERSION:=1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-config-mode
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based config mode for user friendly setup of new meshnodes
  DEPENDS:=+gluon-core +gluon-location +gluon-simple-tc +uhttpd +dnsmasq +luci-mod-admin-core +ip +luci-theme-openwrt +haveged
endef

define Package/gluon-config-mode/description
	Luci based config mode
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode/install
	$(CP) ./files/* $(1)/
	$(GLUON_GENERATE) ./generate/* $(1)/
endef

$(eval $(call BuildPackage,gluon-config-mode))
