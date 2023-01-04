include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page-mesh-batman-adv

include ../gluon.mk

define Package/gluon-status-page-mesh-batman-adv
	TITLE:=Batman-data provider for gluon-status-page
	DEPENDS:=+gluon-status-page gluon-mesh-batman-adv +libnl-tiny +libbatadv +libjson-c
endef

define Package/gluon-status-page-mesh-batman-adv/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neighbours-batadv $(1)/lib/gluon/status-page/providers/
endef

$(eval $(call BuildPackageGluon,gluon-status-page-mesh-batman-adv))
