include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-static-ip

include ../gluon.mk

define Package/gluon-web-static-ip
  DEPENDS:=+gluon-web-admin +gluon-static-ip
  TITLE:=UI for managing static IPs
endef

$(eval $(call BuildPackageGluon,gluon-web-static-ip))
