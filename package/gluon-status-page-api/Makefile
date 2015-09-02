include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page-api
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-status-page-api
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=API for gluon-status-page
  DEPENDS:=+gluon-core +uhttpd +gluon-neighbour-info +gluon-announced +libiwinfo +libjson-c
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/gluon-status-page-api/install
	$(INSTALL_DIR) $(1)/lib/gluon/status-page/www/cgi-bin/dyn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neighbours-batadv $(1)/lib/gluon/status-page/www/cgi-bin/dyn/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/stations $(1)/lib/gluon/status-page/www/cgi-bin/dyn/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-status-page-api))
