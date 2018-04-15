include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page
PKG_VERSION:=3

include ../gluon.mk

define Package/gluon-status-page
  TITLE:=Status page showing information about the node
  DEPENDS:=+gluon-web +gluon-neighbour-info +gluon-respondd +uhttpd +sse-multiplex +libiwinfo +libjson-c +libnl-tiny +libubus-lua
endef

define Package/gluon-status-page/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/stations $(1)/lib/gluon/status-page/providers/

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/view/
	$(LN) /lib/gluon/web/i18n $(1)/lib/gluon/status-page/
	$(LN) /lib/gluon/web/view/error $(1)/lib/gluon/status-page/view/
endef

$(eval $(call BuildPackageGluon,gluon-status-page))
