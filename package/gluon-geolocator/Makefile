include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-geolocator
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

define Package/gluon-geolocator
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Provide the geolocator to receive positions over wifi
  DEPENDS:=+gluon-node-info +micrond
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Package/gluon-geolocator/install
	$(CP) ./files/* $(1)/

endef

define Package/gluon-geolocator/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-geolocator))
