include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-model

include ../gluon.mk

define Package/gluon-web-model
  TITLE:=Minimal Lua web framework derived from LuCI (model support)
  DEPENDS:=+gluon-web
endef

PKG_CONFIG_DEPENDS += CONFIG_GLUON_MINIFY

define Package/gluon-web-model/install
	$(Gluon/Build/Install)
	$(INSTALL_DIR) $(1)/lib/gluon/web/www/static/

ifdef CONFIG_GLUON_MINIFY
	$(INSTALL_DATA) ./javascript/gluon-web-model.min.js $(1)/lib/gluon/web/www/static/gluon-web-model.js
else
	$(INSTALL_DATA) ./javascript/gluon-web-model.js $(1)/lib/gluon/web/www/static/
endif
endef

$(eval $(call BuildPackageGluon,gluon-web-model))
