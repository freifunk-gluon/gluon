include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-geo-location
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-geo-location
  TITLE:=Set geographic location of a node
  DEPENDS:=+gluon-config-mode-core +gluon-node-info
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location))
