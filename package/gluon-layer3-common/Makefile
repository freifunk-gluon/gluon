include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-layer3-common

include ../gluon.mk

define Package/gluon-layer3-common
  TITLE:=Layer3 common files
  DEPENDS:=+gluon-core +gluon-mmfd +firewall
endef

$(eval $(call BuildPackageGluon,gluon-layer3-common))
