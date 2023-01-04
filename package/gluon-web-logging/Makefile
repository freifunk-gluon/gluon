include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-logging

include ../gluon.mk

define Package/gluon-web-logging
	DEPENDS:=+gluon-web-admin
	TITLE:=UI for remote syslog configuration
endef

$(eval $(call BuildPackageGluon,gluon-web-logging))
