# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-theme
PKG_VERSION:=1

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-config-mode-theme
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Gluon config mode theme for gluon-web
  DEPENDS:=+gluon-core +gluon-web
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-theme,i18n)
endef

define Package/gluon-config-mode-theme/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-theme,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-theme))
