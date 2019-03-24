include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-scheduled-domain-switch
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-scheduled-domain-switch
  TITLE:=Allows scheduled migrations between domains
  DEPENDS:=+gluon-core +gluon-check-connection @GLUON_MULTIDOMAIN
endef

$(eval $(call BuildPackageGluon,gluon-scheduled-domain-switch))
