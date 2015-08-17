include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-client-bridge
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-client-bridge
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Provides a bridge and a wireless interface for clients to connect to
  DEPENDS:=+gluon-core
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-client-bridge/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-client-bridge/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-client-bridge))
