include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=node/host

include $(INCLUDE_DIR)/package.mk

define Download/rjs
	FILE:=r.js
	URL:=http://requirejs.org/docs/release/2.1.10
	MD5SUM:=270154b3f5d417c3a42f1e58d03e6607
endef

define Download/Bacon
	FILE:=Bacon.js
	URL:=http://cdnjs.cloudflare.com/ajax/libs/bacon.js/0.7.71
	MD5SUM:=4600a60e1d7ffdb2259dfcce97c860ed
endef

define Download/almond
	FILE:=almond.js
	URL:=https://raw.githubusercontent.com/jrburke/almond/0.3.1
	MD5SUM:=aa66c0c0cb55a4627bb706df73f3aff5
endef

$(eval $(call Download,rjs))
$(eval $(call Download,Bacon))
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
	$(CP) -t $(PKG_BUILD_DIR) $(DL_DIR)/r.js $(DL_DIR)/Bacon.js $(DL_DIR)/almond.js
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
