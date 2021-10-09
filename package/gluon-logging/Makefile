include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-logging

include ../gluon.mk

define Package/gluon-logging
  TITLE:=Configure remote syslog from site.conf
  DEPENDS:=+gluon-core
  CONFLICTS:=gluon-web-logging
endef

$(eval $(call BuildPackageGluon,gluon-logging))

