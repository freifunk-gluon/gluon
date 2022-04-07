include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-private-ap

include ../gluon.mk

define Package/gluon-web-private-ap
  DEPENDS:=+gluon-web-admin +gluon-private-ap
  TITLE:=UI for activating a private AP
endef

$(eval $(call BuildPackageGluon,gluon-web-private-ap))
