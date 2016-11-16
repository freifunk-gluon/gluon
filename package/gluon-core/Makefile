include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core
PKG_VERSION:=3

PKG_CONFIG_DEPENDS := CONFIG_GLUON_VERSION

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk


define Package/gluon-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Base files of Gluon
  DEPENDS:=+gluon-site +libgluonutil +lua-platform-info +lua-hash +luci-base +luci-lib-jsonc +odhcp6c +firewall +pretty-hostname
endef

define Package/gluon-core/description
	Gluon community wifi mesh firmware framework: core
endef

define Package/gluon-core/config
config GLUON_VERSION
        string "Gluon version number"
        depends on PACKAGE_gluon-core
	default ""

config GLUON_SITE_VERSION
        string "Gluon site version number"
        depends on PACKAGE_gluon-core
	default ""
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-core/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon
	echo '$(call qstrip,$(CONFIG_GLUON_VERSION))' > $(1)/lib/gluon/gluon-version
	echo '$(call qstrip,$(CONFIG_GLUON_SITE_VERSION))' > $(1)/lib/gluon/site-version
endef

define Package/gluon-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-core))
