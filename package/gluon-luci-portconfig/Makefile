# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-portconfig
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-luci-portconfig
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci module for advanced ethernet port configuration
  DEPENDS:=+gluon-luci-admin +gluon-client-bridge
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-luci-portconfig,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-luci-portconfig/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-luci-portconfig,$(1))
endef

$(eval $(call BuildPackage,gluon-luci-portconfig))
