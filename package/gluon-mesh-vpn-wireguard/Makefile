include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-wireguard

include ../gluon.mk

define Package/gluon-mesh-vpn-wireguard
  TITLE:=Support for connecting meshes via wireguard
  DEPENDS:=+gluon-core +libgluonutil +gluon-mesh-vpn-core +wireguard-tools +wgpeerselector +libubox +libubus
endef

define Package/gluon-mesh-vpn-wireguard/install
	$(Gluon/Build/Install)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-hex-to-b64 $(1)/usr/sbin/
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-wireguard))
