# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-theme

include ../gluon.mk

define Package/gluon-config-mode-theme
	TITLE:=Gluon config mode theme for gluon-web
	DEPENDS:=+gluon-core +gluon-web
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-theme))
