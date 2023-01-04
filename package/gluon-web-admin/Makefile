# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-admin

include ../gluon.mk

define Package/gluon-web-admin
	TITLE:=Web-based simple administration interface for mesh nodes
	DEPENDS:=+gluon-config-mode-core +pretty-hostname
endef

$(eval $(call BuildPackageGluon,gluon-web-admin))
