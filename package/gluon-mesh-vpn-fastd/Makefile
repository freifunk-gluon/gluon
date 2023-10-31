include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd

include ../gluon.mk

define Package/gluon-mesh-vpn-fastd
  TITLE:=Support for connecting meshes via fastd
  DEPENDS:=+gluon-core +libgluonutil +gluon-mesh-vpn-core +fastd +simple-tc
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-fastd))
