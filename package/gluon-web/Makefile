include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

PKG_INSTALL:=1


define Package/gluon-web
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Minimal Lua web framework derived from LuCI
  DEPENDS:=+luci-lib-jsonc +luci-lib-nixio
endef

define lang-config

config GLUON_WEB_LANG_$(1)
	bool "$(GLUON_LANG_$(1)) language support for gluon-web"
	depends on PACKAGE_gluon-web

endef

define Package/gluon-web/config
$(foreach lang,$(GLUON_SUPPORTED_LANGS),$(call lang-config,$(lang)))
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonBuildI18N,gluon-web,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-web/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-web,$(1))

endef

$(eval $(call BuildPackage,gluon-web))
