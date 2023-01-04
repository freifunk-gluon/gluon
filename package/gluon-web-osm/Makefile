include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-osm

include ../gluon.mk

define Package/gluon-web-osm
	TITLE:=base src for OSM inlay
endef

PKG_CONFIG_DEPENDS += CONFIG_GLUON_MINIFY

define Package/gluon-web-osm/install
	$(Gluon/Build/Install)
	$(INSTALL_DIR) $(1)/lib/gluon/web/www/static/

ifdef CONFIG_GLUON_MINIFY
	$(INSTALL_DATA) ./javascript/gluon-web-osm.min.js $(1)/lib/gluon/web/www/static/gluon-web-osm.js
else
	$(INSTALL_DATA) ./javascript/gluon-web-osm.js $(1)/lib/gluon/web/www/static/
endif
endef

$(eval $(call BuildPackageGluon,gluon-web-osm))
