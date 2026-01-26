include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-site

SITEDIR := $(call qstrip,$(CONFIG_GLUON_SITEDIR))

PKG_CONFIG_DEPENDS := CONFIG_GLUON_SITE_VERSION CONFIG_GLUON_RELEASE CONFIG_GLUON_SITEDIR CONFIG_GLUON_MULTIDOMAIN
PKG_FILE_DEPENDS := $(SITEDIR)/site.conf $(SITEDIR)/domains/ $(SITEDIR)/i18n/
PKG_BUILD_DEPENDS := lua-jsonc/host gluon-web/host

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-site
  TITLE:=Site-specific files of Gluon
endef

define Package/gluon-site/config
config GLUON_SITE_VERSION
	string "Gluon site version number"
	depends on PACKAGE_gluon-site
	default ""

config GLUON_RELEASE
	string "Gluon release number"
	depends on PACKAGE_gluon-site
	default ""

config GLUON_SITEDIR
	string "Gluon site configuration directory"
	depends on PACKAGE_gluon-site
	default ""

config GLUON_MULTIDOMAIN
	bool "Gluon multi-domain support"

endef

define GenerateJSON
	GLUON_SITEDIR='$$(SITEDIR)' GLUON_SITE_CONFIG='$(1).conf' \
		lua -e 'print(require("jsonc").stringify(assert(dofile("../../scripts/site_config.lua")(os.getenv("GLUON_SITE_CONFIG")))))' \
		> '$$(PKG_BUILD_DIR)/$(1).json'
endef

define Build/Compile
	$(call GenerateJSON,site)

  ifdef CONFIG_GLUON_MULTIDOMAIN
	rm -rf $(PKG_BUILD_DIR)/domains
	mkdir -p $(PKG_BUILD_DIR)/domains
	$(foreach domain,$(patsubst $(SITEDIR)/domains/%.conf,%,$(wildcard $(SITEDIR)/domains/*.conf)),
		@if [ -e '$(PKG_BUILD_DIR)/domains/$(domain).json' ]; then \
			link='$(PKG_BUILD_DIR)/domains/$(domain).json'; \
			other="$$$$(basename $$$$(readlink -f "$$$$link") .json)"; \
			if [ "$$$$other" ]; then \
				echo >&2 "Error: Failed to install domain '"'$(domain)'"', name already taken by domain '$$$$other'."; \
			fi; \
			exit 1; \
		fi
		$(call GenerateJSON,domains/$(domain))
		@lua ../../scripts/domain_aliases.lua '$(PKG_BUILD_DIR)/domains/$(domain).json' | while read alias; do \
			[ "$$$${alias}" != '$(domain)' ] || continue; \
			link="$(PKG_BUILD_DIR)/domains/$$$${alias}.json"; \
			if ! ln -s '$(domain).json' "$$$$link"; then \
				other="$$$$(basename $$$$(readlink -f "$$$$link") .json)"; \
				if [ "$$$$other" ]; then \
					echo >&2 "Error: Failed to alias domain '"'$(domain)'"' as '$$$$alias', name already taken by domain '$$$$other'."; \
				fi; \
				exit 1; \
			fi; \
		done
	)
  endif

	$(call GluonBuildI18N,$(SITEDIR)/i18n)
endef

define Package/gluon-site/install
	$(INSTALL_DIR) $(1)/lib/gluon

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/site.json $(1)/lib/gluon/
  ifdef CONFIG_GLUON_MULTIDOMAIN
	$(CP) $(PKG_BUILD_DIR)/domains $(1)/lib/gluon/
  endif

	echo '$(call qstrip,$(CONFIG_GLUON_SITE_VERSION))' > $(1)/lib/gluon/site-version
	echo '$(call qstrip,$(CONFIG_GLUON_RELEASE))' > $(1)/lib/gluon/release

	$(GluonInstallI18N)
endef

$(eval $(call BuildPackageGluon,gluon-site))
