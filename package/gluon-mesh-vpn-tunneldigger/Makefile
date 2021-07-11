include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-tunneldigger
PKG_VERSION:=3

include ../gluon.mk

define Package/gluon-mesh-vpn-tunneldigger
  TITLE:=Support for connecting meshes via tunneldigger/L2TPv3 pseudowire
  DEPENDS:=+gluon-core +gluon-mesh-vpn-core +tunneldigger
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-tunneldigger))
