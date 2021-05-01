include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-private-wifi
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-web-private-wifi
  DEPENDS:=+gluon-web-admin +gluon-private-wifi
  TITLE:=UI for activating a private WLAN
endef

$(eval $(call BuildPackageGluon,gluon-web-private-wifi))
