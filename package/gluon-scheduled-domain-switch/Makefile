include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-scheduled-domain-switch

include ../gluon.mk

define Package/gluon-scheduled-domain-switch
  TITLE:=Allows scheduled migrations between domains
  DEPENDS:=+gluon-core +gluon-state-check @GLUON_MULTIDOMAIN
endef

$(eval $(call BuildPackageGluon,gluon-scheduled-domain-switch))
