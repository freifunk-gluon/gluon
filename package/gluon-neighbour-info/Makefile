include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-neighbour-info
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-neighbour-info
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=neighbour-info
  DEPENDS:=
endef

define Package/gluon-neighbour-info/description
	Gluon community wifi mesh firmware framework: neighbour-info
endef

define Build/Compile
	$(Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-neighbour-info/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-neighbour-info $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gluon-neighbour-info))
