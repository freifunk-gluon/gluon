include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-private-wifi
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-luci-private-wifi
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-luci-admin
  TITLE:=UI for activating a private WLAN
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-luci-private-wifi,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-luci-private-wifi/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-luci-private-wifi,$(1))
endef

$(eval $(call BuildPackage,gluon-luci-private-wifi))
