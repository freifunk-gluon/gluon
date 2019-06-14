include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-offline-ssid
PKG_VERSION:=1

include ../gluon.mk

define Package/$(PKG_NAME)
  TITLE:=adds an option to enable and disable the offline-ssid changer in advanced config mode
  DEPENDS:=+gluon-web-admin +micrond +gluon-offline-ssid
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
