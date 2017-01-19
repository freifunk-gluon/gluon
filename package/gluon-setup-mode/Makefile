# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-setup-mode
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk


define Package/gluon-setup-mode
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Setup mode
  DEPENDS:=+gluon-core +luci-base +uhttpd +dnsmasq
  PROVIDES:=gluon-setup-mode-virtual
endef

define Package/gluon-setup-mode/description
	Offline mode to perform basic setup in a secure manner.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-setup-mode/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

define Package/gluon-setup-mode/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-setup-mode))
