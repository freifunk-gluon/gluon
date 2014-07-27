# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-core
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-config-mode-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based config mode for user friendly setup of new mesh nodes
  DEPENDS:=+gluon-luci-core +gluon-setup-mode +gluon-lock-password
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode-core/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-config-mode-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode-core))
