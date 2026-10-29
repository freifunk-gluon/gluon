include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-network-setup-mode

include ../gluon.mk

define Package/gluon-network-setup-mode
  TITLE:=Network-triggered setup mode activation
  DEPENDS:=+gluon-setup-mode
endef

define Package/gluon-network-setup-mode/description
	Activates setup mode when a request is received on the setup interface
	during boot. Only for devices without a button to activate setup mode.
endef

define Package/gluon-network-setup-mode/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/setup-mode
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wait-network-request $(1)/lib/gluon/setup-mode
endef

$(eval $(call BuildPackageGluon,gluon-network-setup-mode))
