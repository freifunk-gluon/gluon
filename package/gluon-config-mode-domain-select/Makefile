include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-domain-select

include ../gluon.mk

define Package/gluon-config-mode-domain-select
  TITLE:=UI for changing the node-config
  DEPENDS:=+gluon-config-mode-core @GLUON_MULTIDOMAIN
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-domain-select))
