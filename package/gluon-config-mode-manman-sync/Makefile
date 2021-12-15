include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-manman-sync
PKG_VERSION:=2

include ../gluon.mk

define Package/gluon-config-mode-manman-sync
  TITLE:=Sync location data from manman
  DEPENDS:=+gluon-config-mode-core +luci-lib-ip +gluon-manman-sync
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-manman-sync))
