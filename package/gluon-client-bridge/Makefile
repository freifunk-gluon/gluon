include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-client-bridge
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-client-bridge
  TITLE:=Provides a bridge and a wireless interface for clients to connect to
  DEPENDS:=+gluon-core +kmod-veth +@GLUON_SPECIALIZE_KERNEL:KERNEL_VETH
endef

$(eval $(call BuildPackageGluon,gluon-client-bridge))
