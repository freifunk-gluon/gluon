# Copyright (C) 2021 Leonardo Moerlein <me at irrelefant.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-api-contact-info
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-api-contact-info
  TITLE:=Allows the user to provide contact information to be distributed in the mesh
  DEPENDS:=+gluon-config-api-core
endef

$(eval $(call BuildPackageGluon,gluon-config-api-contact-info))
