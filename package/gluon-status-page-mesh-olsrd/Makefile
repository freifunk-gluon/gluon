include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page-mesh-olsrd
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-status-page-mesh-olsrd
  TITLE:=OLSRD-data provider for gluon-status-page
  DEPENDS:=+gluon-status-page +gluon-mesh-olsrd +libjson-c +libubox +libuclient
endef

define Package/gluon-status-page-mesh-olsrd/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neighbours-olsrd $(1)/lib/gluon/status-page/providers/
endef

$(eval $(call BuildPackageGluon,gluon-status-page-mesh-olsrd))
