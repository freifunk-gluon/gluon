include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-autoupdater

include ../gluon.mk

define Package/gluon-config-mode-autoupdater
  TITLE:=Config Mode: Let the user know whether the autoupdater is enabled or not
  DEPENDS:=+gluon-config-mode-core +gluon-autoupdater
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-autoupdater))
