include $(INCLUDE_DIR)/package.mk

# Annoyingly, make's shell function replaces all newlines with spaces, so we have to do some escaping work. Yuck.
define GluonCheckSite
[ -z "$$GLUONDIR" ] || sed -e 's/-@/\n/g' -e 's/+@/@/g' <<'END__GLUON__CHECK__SITE' | "$$GLUONDIR"/scripts/check_site.sh
$(shell cat $(1) | sed -ne '1h; 1!H; $$ {g; s/@/+@/g; s/\n/-@/g; p}')
END__GLUON__CHECK__SITE
endef


# Languages supported by LuCi
GLUON_SUPPORTED_LANGS := ca zh_cn en fr de el he hu it ja ms no pl pt_br pt ro ru es sv uk vi

GLUON_LANG_ca := catalan
GLUON_LANG_zh_cn := chinese
GLUON_LANG_en := english
GLUON_LANG_fr := french
GLUON_LANG_de := german
GLUON_LANG_el := greek
GLUON_LANG_he := hebrew
GLUON_LANG_hu := hungarian
GLUON_LANG_it := italian
GLUON_LANG_ja := japanese
GLUON_LANG_ms := malay
GLUON_LANG_no := norwegian
GLUON_LANG_pl := polish
GLUON_LANG_pt_br := portuguese-brazilian
GLUON_LANG_pt := portuguese
GLUON_LANG_ro := romanian
GLUON_LANG_ru := russian
GLUON_LANG_es := spanish
GLUON_LANG_sv := swedish
GLUON_LANG_uk := ukrainian
GLUON_LANG_vi := vietnamese

GLUON_I18N_PACKAGES := $(foreach lang,$(GLUON_SUPPORTED_LANGS),+GLUON_LANG_$(lang):luci-i18n-$(GLUON_LANG_$(lang)))
GLUON_I18N_CONFIG := $(foreach lang,$(GLUON_SUPPORTED_LANGS),CONFIG_GLUON_LANG_$(lang))
GLUON_ENABLED_LANGS := $(foreach lang,$(GLUON_SUPPORTED_LANGS),$(if $(CONFIG_GLUON_LANG_$(lang)),$(lang)))


GLUON_PO2LMO := $(BUILD_DIR)/luci/build/po2lmo

define GluonBuildI18N
	mkdir -p $$(PKG_BUILD_DIR)/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $(2)/$$$$lang.po ]; then \
			rm -f $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo; \
			$(GLUON_PO2LMO) $(2)/$$$$lang.po $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo; \
		fi; \
	done
endef

define GluonInstallI18N
	$$(INSTALL_DIR) $(2)/usr/lib/lua/luci/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo ]; then \
			$$(INSTALL_DATA) $$(PKG_BUILD_DIR)/i18n/$(1).$$$$lang.lmo $(2)/usr/lib/lua/luci/i18n/$(1).$$$$lang.lmo; \
		fi; \
	done
endef
