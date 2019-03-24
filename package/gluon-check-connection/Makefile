include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-check-connection
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-check-connection
  TITLE:=Checks if a node can ping definable targets
  DEPENDS:=+gluon-core
endef

$(eval $(call BuildPackageGluon,gluon-check-connection))
