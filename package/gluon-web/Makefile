include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web
PKG_VERSION:=1

PKG_INSTALL:=1

include ../gluon.mk

define Package/gluon-web
  TITLE:=Minimal Lua web framework derived from LuCI
  DEPENDS:=+lua-jsonc +luaposix
endef

define lang-config

config GLUON_WEB_LANG_$(1)
	bool "$(GLUON_LANG_$(1)) language support for gluon-web"
	depends on PACKAGE_gluon-web

endef

define Package/gluon-web/config
$(foreach lang,$(GLUON_SUPPORTED_LANGS),$(call lang-config,$(lang)))
endef

$(eval $(call BuildPackageGluon,gluon-web))
