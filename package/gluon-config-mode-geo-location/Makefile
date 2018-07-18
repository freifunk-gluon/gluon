include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-geo-location
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-geo-location
  TITLE:=Set geographic location of a node manualy and share it.
  CONFLICTS:=+gluon-config-mode-geo-location-with-geloc-map +gluon-config-mode-geo-location-with-geloc +gluon-config-mode-geo-location-with-map
  DEPENDS:=+gluon-config-mode-core +gluon-node-info
endef

define Package/gluon-config-mode-geo-location-with-map
  TITLE:=Set geographic location of a node manualy and share it, optionally show a map if internet available.
  CONFLICTS:=+gluon-config-mode-geo-location +gluon-config-mode-geo-location-with-geloc-map +gluon-config-mode-geo-location-with-geloc
  DEPENDS:=+gluon-config-mode-core +gluon-node-info +gluon-web-osm
endef

define Package/gluon-config-mode-geo-location-with-geloc
  TITLE:=Set geographic location of a node manualy or automatically recive geo locations via surrunding wifis and share it.
  CONFLICTS:=+gluon-config-mode-geo-location +gluon-config-mode-geo-location-with-geloc-map +gluon-config-mode-geo-location-with-map
  DEPENDS:=+gluon-config-mode-core +gluon-node-info +gluon-geolocator
endef

define Package/gluon-config-mode-geo-location-with-geloc-map
  TITLE:=Set geographic location of a node manualy or automatically recive geo locations via surrunding wifis and share it, optionally show a map if internet available.
  CONFLICTS:=+gluon-config-mode-geo-location +gluon-config-mode-geo-location-with-geloc +gluon-config-mode-geo-location-with-map
  DEPENDS:=+gluon-config-mode-core +gluon-node-info +gluon-geolocator +gluon-web-osm
endef

define Build/Configure
	$(CP) ./src/* $(PKG_BUILD_DIR)/

	$(INSTALL_DIR) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location{,-with-map,-with-geloc,-with-geloc-map}/{luasrc/lib/gluon/config-mode/wizard/,i18n/}
endef

define Build/Compile
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/gluon-config-mode-geo-location.pot
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/check_site.lua
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/de.po
	$(CC) -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n/fr.po
	$(call GluonBuildI18N,gluon-config-mode-geo-location,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/i18n)
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luadest/)

	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/gluon-config-mode-geo-location-with-map.pot
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/check_site.lua
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/de.po
	$(CC) -DWITHMAP -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n/fr.po
	$(call GluonBuildI18N,gluon-config-mode-geo-location-with-map,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/i18n)
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luadest/)

	$(CC) -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/i18n/gluon-config-mode-geo-location-with-geloc.pot
	$(CC) -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/check_site.lua
	$(CC) -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/i18n/de.po
	$(CC) -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/i18n/fr.po
	$(call GluonBuildI18N,gluon-config-mode-geo-location-with-geloc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/i18n)
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/luadest/)

	$(CC) -DWITHMAP -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/0400-geo-location.lua.in -o  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/luasrc/lib/gluon/config-mode/wizard/0400-geo-location.lua
	$(CC) -DWITHMAP -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/gluon-config-mode-geo-location.pot.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/i18n/gluon-config-mode-geo-location-with-geloc-map.pot
	$(CC) -DWITHMAP -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/check_site.lua.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/check_site.lua
	$(CC) -DWITHMAP -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/de.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/i18n/de.po
	$(CC) -DWITHMAP -DWITHGELOC -E -x c -P  $(PKG_BUILD_DIR)/fr.po.in -o $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/i18n/fr.po
	$(call GluonBuildI18N,gluon-config-mode-geo-location-with-geloc-map,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/i18n)
	$(call GluonSrcDiet,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/luasrc,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/luadest/)
endef

define Package/gluon-config-mode-geo-location/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-geo-location,$(1))
endef

define Package/gluon-config-mode-geo-location-with-map/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/config-mode/www/static/
	$(LN) /lib/gluon/web/www/static/osm.js $(1)/lib/gluon/config-mode/www/static/osm.js
	$(call GluonInstallI18N,gluon-config-mode-geo-location-with-map,$(1))
endef

define Package/gluon-config-mode-geo-location-with-geloc/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-geo-location-with-geloc,$(1))
endef

define Package/gluon-config-mode-geo-location-with-geloc-map/install
	$(CP) $(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/config-mode/www/static/
	$(LN) /lib/gluon/web/www/static/osm.js $(1)/lib/gluon/config-mode/www/static/osm.js
	$(call GluonInstallI18N,gluon-config-mode-geo-location-with-geloc-map,$(1))
endef

define Package/gluon-config-mode-geo-location/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location/check_site.lua)
endef

define Package/gluon-config-mode-geo-location-with-map/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-map/check_site.lua)
endef

define Package/gluon-config-mode-geo-location-with-geloc/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc/check_site.lua)
endef

define Package/gluon-config-mode-geo-location-with-geloc-map/postinst
#!/bin/sh
$(call GluonCheckSite,$(PKG_BUILD_DIR)/gluon-config-mode-geo-location-with-geloc-map/check_site.lua)
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location))
$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location-with-map))
$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location-with-geloc))
$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location-with-geloc-map))
