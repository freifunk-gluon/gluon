include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-neighbour-info

include ../gluon.mk

define Package/gluon-neighbour-info
  TITLE:=neighbour-info
  DEPENDS:=
endef

define Package/gluon-neighbour-info/description
	Gluon community wifi mesh firmware framework: neighbour-info
endef

define Package/gluon-neighbour-info/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-neighbour-info $(1)/usr/bin/
endef

$(eval $(call BuildPackageGluon,gluon-neighbour-info))
