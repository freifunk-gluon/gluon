GLUON_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
PKG_FILE_DEPENDS += $(GLUON_MK)

PKG_VERSION ?= 1

PKG_BUILD_DEPENDS += luasrcdiet/host

ifneq ($(wildcard ./luasrc/.),)
  PKG_CONFIG_DEPENDS += CONFIG_GLUON_MINIFY
endif

ifneq ($(wildcard ./src/respondd.c),)
  PKG_BUILD_DEPENDS += respondd
endif

include $(INCLUDE_DIR)/package.mk


# Annoyingly, make's shell function replaces all newlines with spaces, so we have to do some escaping work. Yuck.
shell-escape = $(shell $(1) | sed -ne '1h; 1!H; $$ {g; s/@/@1/g; s/\n/@2/g; p}')
shell-unescape = $(subst @1,@,$(subst @2,$(newline),$(1)))
shell-verbatim = $(call shell-unescape,$(call shell-escape,$(1)))


define GluonCheckSite
[ -z "$$STAGING_DIR_HOSTPKG" ] || PATH="$$STAGING_DIR_HOSTPKG/bin:$$PATH"
LUA_PATH="$$IPKG_INSTROOT/usr/lib/lua/?.lua" lua "$$IPKG_INSTROOT/lib/gluon/check-site.lua" <<'END__GLUON__CHECK__SITE'
$(call shell-verbatim,cat '$(1)')
END__GLUON__CHECK__SITE
endef

GLUON_SUPPORTED_LANGS := de fr
GLUON_LANG_de := German
GLUON_LANG_fr := French

GLUON_I18N_CONFIG := $(foreach lang,$(GLUON_SUPPORTED_LANGS),CONFIG_GLUON_WEB_LANG_$(lang))
GLUON_ENABLED_LANGS := en $(foreach lang,$(GLUON_SUPPORTED_LANGS),$(if $(CONFIG_GLUON_WEB_LANG_$(lang)),$(lang)))

ifneq ($(wildcard ./i18n/.),)
  PKG_BUILD_DEPENDS += gluon-web/host
  PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)
endif


define GluonBuildI18N
	mkdir -p $$(PKG_BUILD_DIR)/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $(1)/$$$$lang.po ]; then \
			rm -f $$(PKG_BUILD_DIR)/i18n/$$$$lang.lmo; \
			gluon-po2lmo $(1)/$$$$lang.po $$(PKG_BUILD_DIR)/i18n/$$$$lang.lmo; \
		fi; \
	done
endef

define GluonInstallI18N
	$$(INSTALL_DIR) $(1)/lib/gluon/web/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $$(PKG_BUILD_DIR)/i18n/$$$$lang.lmo ]; then \
			$$(INSTALL_DATA) $$(PKG_BUILD_DIR)/i18n/$$$$lang.lmo $(1)/lib/gluon/web/i18n/$(PKG_NAME).$$$$lang.lmo; \
		fi; \
	done
endef

define GluonSrcDiet
	rm -rf $(2)
	$(CP) $(1) $(2)
  ifdef CONFIG_GLUON_MINIFY
	# Use cp + rm instead of mv to preserve destination permissions
	set -e; $(FIND) $(2) -type f | while read src; do \
		echo "Minifying $$$$src..."; \
		luasrcdiet --noopt-binequiv -o "$$$$src.tmp" "$$$$src"; \
		cp "$$$$src.tmp" "$$$$src"; \
		rm "$$$$src.tmp"; \
	done
  endif
endef


define Gluon/Build/Compile
	$(if $(wildcard ./src/Makefile ./src/CMakeLists.txt),
		$(Build/Compile/Default)
	)
	$(if $(wildcard ./luasrc/.),
		$(call GluonSrcDiet,luasrc,$(PKG_BUILD_DIR)/luadest/)
	)
	$(if $(wildcard ./i18n/.),
		$(call GluonBuildI18N,i18n)
	)
endef

define Gluon/Build/Install
	$(if $(findstring $(PKG_INSTALL),1),
		$(CP) $(PKG_INSTALL_DIR)/. $(1)/
	)
	$(if $(wildcard ./files/.),
		$(CP) ./files/. $(1)/
	)
	$(if $(wildcard ./luasrc/.),
		$(CP) $(PKG_BUILD_DIR)/luadest/. $(1)/
	)
	$(if $(wildcard ./src/respondd.c),
		$(INSTALL_DIR) $(1)/usr/lib/respondd
		$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/usr/lib/respondd/$(PKG_NAME).so
	)
	$(if $(wildcard ./i18n/.),
		$(GluonInstallI18N)
	)
endef

Build/Compile=$(call Gluon/Build/Compile)

define BuildPackageGluon
  define Package/$(1) :=
    SECTION:=gluon
    CATEGORY:=Gluon
    $$(Package/$(1))
  endef

  Package/$(1)/install ?= $$(Gluon/Build/Install)

  ifneq ($(wildcard check_site.lua),)
    define Package/$(1)/postinst
#!/bin/sh
$$(call GluonCheckSite,check_site.lua)
    endef
  endif

  $$(eval $$(call BuildPackage,$(1)))
endef
