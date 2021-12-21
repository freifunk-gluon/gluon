include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-lib-ecdsa
PKG_VERSION=1

include ../gluon.mk

define Package/gluon-lib-ecdsa
  TITLE:=Lua bindings for ecdsautil
  DEPENDS:=+liblua +libecdsautil
endef

define Package/gluon-lib-ecdsa/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/usr/lib/lua/gluon
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ecdsa.so $(1)/usr/lib/lua/gluon/
endef

$(eval $(call BuildPackageGluon,gluon-lib-ecdsa))
