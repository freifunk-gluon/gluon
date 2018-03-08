include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-model
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-web-model
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Minimal Lua web framework derived from LuCI (model support)
  DEPENDS:=+gluon-web
endef

$(eval $(call BuildPackageGluon,gluon-web-model))
