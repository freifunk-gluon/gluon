include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page
PKG_VERSION:=3

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-status-page
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Status page showing information about the node
  DEPENDS:=+gluon-web +gluon-neighbour-info +gluon-respondd +uhttpd +sse-multiplex +libiwinfo +libjson-c +libnl-tiny +libubus-lua +libbatadv
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
	$(call GluonBuildI18N,gluon-status-page,i18n)
endef

define Package/gluon-status-page/install
	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/{neighbours-batadv,stations} $(1)/lib/gluon/status-page/providers/

	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/view/
	$(LN) /lib/gluon/web/i18n $(1)/lib/gluon/status-page/
	$(LN) /lib/gluon/web/view/error $(1)/lib/gluon/status-page/view/

	$(call GluonInstallI18N,gluon-status-page,$(1))
endef

$(eval $(call BuildPackage,gluon-status-page))
