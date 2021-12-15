include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-manman-sync
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-manman-sync
  DEPENDS:=+gluon-core +micrond
  TITLE:=Sync configuration with data from manman
endef

$(eval $(call BuildPackageGluon,gluon-manman-sync))
