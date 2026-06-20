# Copyright (C) 2021 Leonardo Moerlein <me at irrelefant.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-api-core
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-api-core
  TITLE:=Provides a REST API to configure the gluon node
  DEPENDS:=+gluon-web +uhttpd +libucl +gluon-config-mode-core
endef

$(eval $(call BuildPackageGluon,gluon-config-api-core))
