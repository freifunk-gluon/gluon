include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-site

GLUON_SITEDIR = '$(call qstrip,$(CONFIG_GLUON_SITEDIR))'
GLUON_SITE_VERSION = $(shell ( cd $(GLUON_SITEDIR) && git --git-dir=.git describe --always --dirty=+ ) 2>/dev/null || echo unknown)
PKG_VERSION:=$(if $(DUMP),x,$(GLUON_SITE_VERSION))


PKG_CONFIG_DEPENDS := CONFIG_GLUON_RELEASE CONFIG_GLUON_SITEDIR
PKG_FILE_DEPENDS := $(GLUON_SITEDIR)/site.conf $(GLUON_SITEDIR)/domains/ $(GLUON_SITEDIR)/i18n/
PKG_BUILD_DEPENDS := lua-cjson/host

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-site
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Site-specific files of Gluon
endef

define Package/gluon-site/config
config GLUON_RELEASE
	string "Gluon release number"
	depends on PACKAGE_gluon-site
	default ""

config GLUON_SITEDIR
	string "Gluon site configuration directory"
	depends on PACKAGE_gluon-site
	default ""
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)/domains
endef

define Build/Configure
endef

define Build/Compile
	GLUON_SITEDIR='$(call qstrip,$(CONFIG_GLUON_SITEDIR))' lua -e 'print(require("cjson").encode(assert(dofile("../../scripts/site_config.lua"))))' > $(PKG_BUILD_DIR)/site.json
	ls $(call qstrip,$(CONFIG_GLUON_SITEDIR))/domains/*.conf > /dev/null # at least one domain cfg has to exist
	GLUON_SITEDIR='$(call qstrip,$(CONFIG_GLUON_SITEDIR))' lua -e 'print(assert(dofile("../../scripts/site_config.lua")).default_domain_code)' > $(PKG_BUILD_DIR)/default_domain_code
	ls '$(call qstrip,$(CONFIG_GLUON_SITEDIR))'/domains/$$$$(cat $(PKG_BUILD_DIR)/default_domain_code).conf # ensure default_domain_code exists
	for domain_cfg in `find $(call qstrip,$(CONFIG_GLUON_SITEDIR))/domains/ -iname \*.conf -printf "%f\n"`; do dc=$$$${domain_cfg%.conf}; GLUON_SITEDIR='$(call qstrip,$(CONFIG_GLUON_SITEDIR))' lua -e 'print(require("cjson").encode(assert(dofile("../../scripts/domain_config.lua")("'$$$${dc}'"))))' > $(PKG_BUILD_DIR)/domains/$$$${dc}.json; done
	$(call GluonBuildI18N,gluon-site,$(GLUON_SITEDIR)/i18n)
endef

define Package/gluon-site/install
	$(INSTALL_DIR) $(1)/lib/gluon
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/site.json $(1)/lib/gluon/
	$(INSTALL_DIR) $(1)/lib/gluon/domains
	$(CP) $(PKG_BUILD_DIR)/domains/*.json $(1)/lib/gluon/domains/
	echo '$(GLUON_SITE_VERSION)' > $(1)/lib/gluon/site-version
	echo '$(call qstrip,$(CONFIG_GLUON_RELEASE))' > $(1)/lib/gluon/release

	$(call GluonInstallI18N,gluon-site,$(1))
endef

$(eval $(call BuildPackage,gluon-site))
