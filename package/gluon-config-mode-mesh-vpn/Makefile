include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-mesh-vpn

include ../gluon.mk

define Package/gluon-config-mode-mesh-vpn
  TITLE:=Toggle mesh-vpn and bandwidth limit
  DEPENDS:=+gluon-config-mode-core +gluon-mesh-vpn-core
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-mesh-vpn))
