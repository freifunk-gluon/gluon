# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode
PKG_VERSION:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-config-mode
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based config mode for user friendly setup of new mesh nodes
  DEPENDS:=+gluon-luci-core +gluon-setup-mode +gluon-lock-password +gluon-node-info +gluon-simple-tc
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
endef

define Package/gluon-config-mode/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode))
