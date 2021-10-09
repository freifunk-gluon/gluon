include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-model

include ../gluon.mk

define Package/gluon-web-model
  TITLE:=Minimal Lua web framework derived from LuCI (model support)
  DEPENDS:=+gluon-web
endef

$(eval $(call BuildPackageGluon,gluon-web-model))
