# Dependencies for LuaSrcDiet
PKG_BUILD_DEPENDS += luci-base/host

include $(INCLUDE_DIR)/package.mk

# Annoyingly, make's shell function replaces all newlines with spaces, so we have to do some escaping work. Yuck.
define GluonCheckSite
[ -z "$$IPKG_INSTROOT" ] || sed -e 's/-@/\n/g' -e 's/+@/@/g' <<'END__GLUON__CHECK__SITE' | "${TOPDIR}/staging_dir/hostpkg/bin/lua" -e 'dofile()'
local f = assert(io.open(os.getenv('IPKG_INSTROOT') .. '/lib/gluon/site.json'))
local site_json = f:read('*a')
f:close()

site = require('cjson').decode(site_json)
$(shell cat '$(TOPDIR)/../scripts/check_site_lib.lua' '$(1)' | sed -ne '1h; 1!H; $$ {g; s/@/+@/g; s/\n/-@/g; p}')
END__GLUON__CHECK__SITE
endef

GLUON_SUPPORTED_LANGS := de fr
GLUON_LANG_de := German
GLUON_LANG_fr := French

GLUON_I18N_CONFIG := $(foreach lang,$(GLUON_SUPPORTED_LANGS),CONFIG_GLUON_WEB_LANG_$(lang))
GLUON_ENABLED_LANGS := en $(foreach lang,$(GLUON_SUPPORTED_LANGS),$(if $(CONFIG_GLUON_WEB_LANG_$(lang)),$(lang)))


define GluonBuildI18N
	mkdir -p $$(PKG_BUILD_DIR)/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $(2)/$$$$lang.po ]; then \
			rm -f $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo; \
			po2lmo $(2)/$$$$lang.po $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo; \
		fi; \
	done
endef

define GluonInstallI18N
	$$(INSTALL_DIR) $(2)/lib/gluon/web/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo ]; then \
			$$(INSTALL_DATA) $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo $(2)/lib/gluon/web/i18n/$(1).$$$$lang.lmo; \
		fi; \
	done
endef

define GluonSrcDiet
	rm -rf $(2)
	$(CP) $(1) $(2)
	$(FIND) $(2) -type f | while read src; do \
		if LuaSrcDiet --noopt-binequiv -o "$$$$src.o" "$$$$src"; then \
			chmod $$$$(stat -c%a "$$$$src") "$$$$src.o"; \
			mv "$$$$src.o" "$$$$src"; \
		fi; \
	done
endef
