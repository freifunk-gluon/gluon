# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-theme
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk


define Package/gluon-web-theme
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=gluon-web theme
  DEPENDS:=+pretty-hostname
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-web-theme/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-web-theme))
