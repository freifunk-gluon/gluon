include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-static-ip
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-static-ip
  TITLE:=Static IP assignment and configuration for gluon
  DEPENDS:=+gluon-core +luci-lib-ip
endef

$(eval $(call BuildPackageGluon,gluon-static-ip))
