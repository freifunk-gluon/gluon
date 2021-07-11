include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd
PKG_VERSION:=3

include ../gluon.mk

define Package/gluon-mesh-vpn-fastd
  TITLE:=Support for connecting meshes via fastd
  DEPENDS:=+gluon-core +libgluonutil +gluon-mesh-vpn-core +fastd
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-fastd))
