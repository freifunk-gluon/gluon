include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-mesh-vpn-openvpn

include ../gluon.mk

define Package/gluon-web-mesh-vpn-openvpn
  TITLE:=gluon-web module to upload keys for openvpn mesh-vpn
  DEPENDS:=+gluon-web-admin +gluon-mesh-vpn-openvpn +lua-openssl
endef

$(eval $(call BuildPackageGluon,gluon-web-mesh-vpn-openvpn))
