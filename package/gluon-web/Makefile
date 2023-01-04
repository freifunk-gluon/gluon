include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web

PKG_INSTALL:=1

include ../gluon.mk
include $(INCLUDE_DIR)/host-build.mk

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

define Host/Prepare
	$(CP) ./src/* $(HOST_BUILD_DIR)
endef

define Host/Compile
	$(call Host/Compile/Default,gluon-po2lmo)
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/gluon-po2lmo $(1)/bin/
endef

$(eval $(call BuildPackageGluon,gluon-web))
$(eval $(call HostBuild))
