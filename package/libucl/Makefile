#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libucl
PKG_VERSION:=0.8.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/vstakhov/libucl
PKG_SOURCE_VERSION:=e6c5d8079b95796099693b0889f07a036f78ad77
PKG_MAINTAINER:=Leonardo Mörlein <me@irrelefant.net>

PKG_LICENSE:=BSD-2-Clause

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

CONFIGURE_ARGS += \
	--enable-lua

define Package/libucl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Config Parsing
  DEPENDS:=+liblua
  URL:=https://github.com/vstakhov/libucl
endef

define Package/libucl/description
  Universal configuration library parser.
endef

define Package/libucl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libucl.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libucl.so.5 $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libucl.so.5.1.0 $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/lua/.libs/ucl.so $(1)/usr/lib/lua/ucl.so
endef


$(eval $(call BuildPackage,libucl))
