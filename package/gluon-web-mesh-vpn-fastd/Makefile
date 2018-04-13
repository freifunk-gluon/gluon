include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-mesh-vpn-fastd
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-web-mesh-vpn-fastd
  TITLE:=gluon-web module to enable and disable encryption for the mesh VPN
  DEPENDS:=+gluon-web-admin +gluon-mesh-vpn-fastd
endef

$(eval $(call BuildPackageGluon,gluon-web-mesh-vpn-fastd))
