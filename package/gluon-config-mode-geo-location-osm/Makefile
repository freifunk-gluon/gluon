include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-geo-location-osm

include ../gluon.mk

define Package/gluon-config-mode-geo-location-osm
  TITLE:=Set geographic location of a node (map support)
  DEPENDS:=+gluon-config-mode-geo-location +gluon-web-osm
endef

define Package/gluon-config-mode-geo-location-osm/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/config-mode/www/static/
	$(LN) /lib/gluon/web/www/static/gluon-web-osm.min.js $(1)/lib/gluon/config-mode/www/static/gluon-web-osm.js
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-geo-location-osm))
