# Copyright (C) 2021 Maciej Krüger <maciej at xeredo.it>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-theme-funkfeuer
PKG_VERSION:=1

include ../gluon.mk

# TODO: don't use this gigantic hack
define Build/Prepare
	cp -rpn ../gluon-config-mode-theme/* .
endef

define Package/gluon-config-mode-theme-funkfeuer
  TITLE:=Gluon config mode theme for gluon-web customized for funkfeuer
  DEPENDS:=+gluon-core +gluon-web
	PROVIDES:=gluon-config-mode-theme
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-theme-funkfeuer))
