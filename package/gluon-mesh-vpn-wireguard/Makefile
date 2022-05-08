include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-wireguard

include ../gluon.mk

define Package/gluon-mesh-vpn-wireguard
  TITLE:=Support for connecting meshes via wireguard
  DEPENDS:=+gluon-core +libgluonutil +gluon-mesh-vpn-core +wireguard-tools +wgpeerselector +libubus
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-wireguard))
