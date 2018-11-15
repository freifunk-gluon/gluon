include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alt-esc-client
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-alt-esc-client
  DEPENDS:=+gluon-web-admin \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_DNAT \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_REDIRECT
  TITLE:=Gluon Alternative Exit Service Collaborator - Client
endef

$(eval $(call BuildPackageGluon,gluon-alt-esc-client))
