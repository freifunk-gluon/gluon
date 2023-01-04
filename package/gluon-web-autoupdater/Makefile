# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-autoupdater

include ../gluon.mk

define Package/gluon-web-autoupdater
	TITLE:=gluon-web module for gluon-autoupdater
	DEPENDS:=+gluon-web-admin +gluon-autoupdater
endef

$(eval $(call BuildPackageGluon,gluon-web-autoupdater))
