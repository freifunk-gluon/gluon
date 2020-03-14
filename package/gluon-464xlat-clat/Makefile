include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-464xlat-clat
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-464xlat-clat
  TITLE:=Support translating IPv4 addresses to IPv6 using 464xlat
  DEPENDS:=+gluon-core +kmod-nat46
endef

$(eval $(call BuildPackageGluon,gluon-464xlat-clat))
