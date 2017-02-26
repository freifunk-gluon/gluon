include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=node/host

include $(INCLUDE_DIR)/package.mk


RJS_VERSION:=2.1.10
RJS:=r-$(RJS_VERSION).js
define Download/rjs
	FILE:=$(RJS)
	URL:=http://requirejs.org/docs/release/$(RJS_VERSION)
	URL_FILE:=r.js
	HASH:=d0b7cfd962a7f8ac52a5d528df486341eed856609d9c75fa2566a32900f5b143
endef
$(eval $(call Download,rjs))

BACON_VERSION:=0.7.71
BACON:=Bacon-$(BACON_VERSION).js
define Download/Bacon
	FILE:=$(BACON)
	URL:=http://cdnjs.cloudflare.com/ajax/libs/bacon.js/$(BACON_VERSION)
	URL_FILE:=Bacon.js
	HASH:=93d840d2167964ced7c53598f7d07151c3bfb1d8a7c3e8cff44cadd7dea25f1d
endef
$(eval $(call Download,Bacon))

ALMOND_VERSION:=0.3.1
ALMOND:=almond-$(ALMOND_VERSION).js
define Download/almond
	FILE:=$(ALMOND)
	URL:=https://raw.githubusercontent.com/jrburke/almond/$(ALMOND_VERSION)
	URL_FILE:=almond.js
	HASH:=3df2baac13da29dab646f9b9ddd2c5e09d91a49ae3a4f3befb40ce1dd60937f2
endef
$(eval $(call Download,almond))

define Package/gluon-status-page
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Adds a status page showing information about the node.
  DEPENDS:=+gluon-status-page-api
endef

define Package/gluon-status-page/description
	Adds a status page showing information about the node.
	Especially useful in combination with the next-node feature.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(RJS) $(PKG_BUILD_DIR)/r.js
	$(CP) $(DL_DIR)/$(BACON) $(PKG_BUILD_DIR)/Bacon.js
	$(CP) $(DL_DIR)/$(ALMOND) $(PKG_BUILD_DIR)/almond.js
endef

define Build/Configure
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
		node r.js -o build.js && \
		node r.js -o cssIn=css/main.css out=style.css && \
		$(M4) index.html.m4 > index.html
endef

define Package/gluon-status-page/install
	$(INSTALL_DIR) $(1)/lib/gluon/status-page/www/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/index.html $(1)/lib/gluon/status-page/www/
endef

$(eval $(call BuildPackage,gluon-status-page))
