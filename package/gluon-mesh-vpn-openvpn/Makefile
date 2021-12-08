include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-openvpn
PKG_VERSION:=3

include ../gluon.mk

define Package/gluon-mesh-vpn-openvpn
  TITLE:=Support for connecting meshes via custom openvpn configuration
  DEPENDS:=+gluon-core +gluon-mesh-vpn-core +openvpn
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-openvpn))
