include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-geo-location
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-geo-location
  TITLE:=Set geographic location of a node and share it.
  CONFLICTS:=+gluon-config-mode-geo-location-with-map
  DEPENDS:=+gluon-config-mode-core +gluon-node-info
endef

define Package/gluon-config-mode-geo-location-with-map
  TITLE:=Set geographic location of a node and share it, additionally show a map if internet is available.
  CONFLICTS:=+gluon-config-mode-geo-location
  DEPENDS:=+gluon-config-mode-core +gluon-node-info +gluon-web-osm
endef

define Build/Configure
	$(CP) ./src/* $(PKG_BUILD_DIR)/

	$(INSTALL_DIR) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location{,-with-map}/{luasrc/lib/gluon/config-mode/wizard/,i18n/}
endef

define GluonBuildI18N
	mkdir -p $(1)
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $(1)/$$$$lang.po ]; then \
			rm -f $(1)/$$$$lang.lmo; \
			po2lmo $(1)/$$$$lang.po $(1)/$$$$lang.lmo; \
		fi; \
	done
endef

define GluonInstallI18N
	$(INSTALL_DIR) $(1)/lib/gluon/web/i18n
	for lang in $$(GLUON_ENABLED_LANGS); do \
		if [ -e $(2)/i18n/$$$$lang.lmo ]; then \
			$(INSTALL_DATA) $(2)/i18n/$$$$lang.lmo $(1)/lib/gluon/web/i18n/$(PKG_NAME).$$$$lang.lmo; \
		fi; \
	done
endef


define Build/Compile
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/gluon-config-mode-geo-location.pot
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/check_site.lua
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/de.po
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/fr.po
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luadest/)
	$(call GluonBuildI18N,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n)

	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/gluon-config-mode-geo-location-with-map.pot
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/check_site.lua
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/de.po
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/fr.po
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luadest/)
	$(call GluonBuildI18N,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n)
endef

define Package/gluon-config-mode-geo-location/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luadest/* $(1)/
	$(call GluonInstallI18N,$(1),$(PKG_BUILD_DIR)/gluon-config-mode-geo-location)
endef

define Package/gluon-config-mode-geo-location-with-map/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/config-mode/www/static/
	$(LN) /lib/gluon/web/www/static/osm.js $(1)/lib/gluon/config-mode/www/static/osm.js
	$(call GluonInstallI18N,$(1),$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map)
endef

define Package/gluon-config-mode-geo-location/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/check_site.lua)
endef

define Package/gluon-config-mode-geo-location-with-map/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/check_site.lua)
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location))
$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location-with-map))
