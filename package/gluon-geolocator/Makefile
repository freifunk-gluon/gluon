include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-geolocator
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-geolocator
  TITLE:=Provide the geolocator to receive positions over wifi
  DEPENDS:=+gluon-node-info +micrond
endef

$(eval $(call BuildPackageGluon,gluon-geolocator))
