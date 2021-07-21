include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-node-info
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-node-info
  TITLE:=Add /etc/config/gluon-node-info to uci
  DEPENDS:=+gluon-core +libgluonutil
endef

define Package/gluon-node-info/conffiles
/etc/config/gluon-node-info
endef

$(eval $(call BuildPackageGluon,gluon-node-info))
