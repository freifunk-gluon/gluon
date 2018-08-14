include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-wifi-config
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-web-wifi-config
  DEPENDS:=+gluon-web-admin +libiwinfo-lua
  TITLE:=UI for Wifi Settings
endef

$(eval $(call BuildPackageGluon,gluon-web-wifi-config))
