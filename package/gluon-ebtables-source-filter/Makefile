include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-source-filter
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk


define Package/gluon-ebtables-source-filter
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Ebtables rules to filter unreasonable L2 traffic.
  DEPENDS:=+gluon-core +gluon-ebtables
endef

define Package/gluon-ebtables-source-filter/description
	This package adds an additional layer-2 filter-ruleset to prevent unreasonable
	traffic entering the network via the nodes.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ebtables-source-filter/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-ebtables-source-filter/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-ebtables-source-filter))
