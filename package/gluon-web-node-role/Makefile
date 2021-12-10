include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-node-role

include ../gluon.mk

define Package/gluon-web-node-role
  DEPENDS:=+gluon-web-admin +gluon-node-info
  TITLE:=UI for specifying node role
endef

$(eval $(call BuildPackageGluon,gluon-web-node-role))
