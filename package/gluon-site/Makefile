include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-site
PKG_VERSION:=$(if $(GLUON_SITE_CODE),$(GLUON_SITE_CODE),1)
PKG_RELEASE:=$(GLUON_RELEASE)

PKG_FILE_DEPENDS := $(GLUON_SITEDIR)/site.conf $(GLUON_SITEDIR)/i18n/
PKG_BUILD_DEPENDS := luci-base/host lua-cjson/host

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-site
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Site-specific files of Gluon
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-site,$(GLUON_SITEDIR)/i18n)
endef

define Package/gluon-site/install
	$(INSTALL_DIR) $(1)/lib/gluon
	lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/site.json
	echo "$(GLUON_RELEASE)" > $(1)/lib/gluon/release

	$(call GluonInstallI18N,gluon-site,$(1))
endef

$(eval $(call BuildPackage,gluon-site))
