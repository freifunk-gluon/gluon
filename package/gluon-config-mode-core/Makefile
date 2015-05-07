# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-core
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based config mode for user friendly setup of new mesh nodes
  DEPENDS:=gluon-setup-mode-virtual +gluon-luci-theme +gluon-lock-password $(GLUON_I18N_PACKAGES)
  PROVIDES:=gluon-config-mode-core-virtual
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-core,i18n)
endef

define Package/gluon-config-mode-core/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-core,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-core))
