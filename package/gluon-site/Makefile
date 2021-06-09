include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-site

GLUON_SITEDIR = $(call qstrip,$(CONFIG_GLUON_SITEDIR))
GLUON_SITE_VERSION = $(shell ( cd '$(GLUON_SITEDIR)' && git --git-dir=.git describe --always --dirty=+ ) 2>/dev/null || echo unknown)
PKG_VERSION:=$(if $(DUMP),x,$(GLUON_SITE_VERSION))

PKG_CONFIG_DEPENDS := CONFIG_GLUON_RELEASE CONFIG_GLUON_SITEDIR CONFIG_GLUON_MULTIDOMAIN
PKG_FILE_DEPENDS := $(GLUON_SITEDIR)/site.conf $(GLUON_SITEDIR)/domains/ $(GLUON_SITEDIR)/i18n/
PKG_BUILD_DEPENDS := lua-jsonc/host gluon-web/host

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-site
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

config GLUON_MULTIDOMAIN
	bool "Gluon multi-domain support"

endef

define GenerateJSON
	GLUON_SITEDIR='$$(GLUON_SITEDIR)' GLUON_SITE_CONFIG='$(1).conf' \
		lua -e 'print(require("jsonc").stringify(assert(dofile("../../scripts/site_config.lua")(os.getenv("GLUON_SITE_CONFIG")))))' \
		> '$$(PKG_BUILD_DIR)/$(1).json'
endef

define Build/Compile
	$(call GenerateJSON,site)

  ifdef CONFIG_GLUON_MULTIDOMAIN
	rm -rf $(PKG_BUILD_DIR)/domains
	mkdir -p $(PKG_BUILD_DIR)/domains
	$(foreach domain,$(patsubst $(GLUON_SITEDIR)/domains/%.conf,%,$(wildcard $(GLUON_SITEDIR)/domains/*.conf)),
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

	$(call GluonBuildI18N,$(GLUON_SITEDIR)/i18n)
endef

define Package/gluon-site/install
	$(INSTALL_DIR) $(1)/lib/gluon

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/site.json $(1)/lib/gluon/
  ifdef CONFIG_GLUON_MULTIDOMAIN
	$(CP) $(PKG_BUILD_DIR)/domains $(1)/lib/gluon/
  endif

	echo '$(GLUON_SITE_VERSION)' > $(1)/lib/gluon/site-version
	echo '$(call qstrip,$(CONFIG_GLUON_RELEASE))' > $(1)/lib/gluon/release

	$(GluonInstallI18N)
endef

$(eval $(call BuildPackageGluon,gluon-site))
