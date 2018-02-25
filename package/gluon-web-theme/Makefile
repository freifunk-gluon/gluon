# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-theme
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-web-theme
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=gluon-web theme
  DEPENDS:=+gluon-core +gluon-web
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-web-theme,i18n)
endef

define Package/gluon-web-theme/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-web-theme,$(1))
endef

$(eval $(call BuildPackage,gluon-web-theme))
