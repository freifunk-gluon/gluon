# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-setup-mode
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-setup-mode
  TITLE:=Setup mode
  DEPENDS:=+gluon-core +gluon-lock-password +ubus +dnsmasq
endef

define Package/gluon-setup-mode/description
	Offline mode to perform basic setup in a secure manner.
endef

$(eval $(call BuildPackageGluon,gluon-setup-mode))
