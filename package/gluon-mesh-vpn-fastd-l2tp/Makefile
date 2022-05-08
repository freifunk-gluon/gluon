include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd-l2tp
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-vpn-fastd-l2tp
  TITLE:=Support for connecting meshes via fastd (with L2TP kernel offloading)
  DEPENDS:=+gluon-core +gluon-mesh-vpn-fastd +kmod-l2tp-eth
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-fastd-l2tp))
