include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-tunneldigger
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-tunneldigger
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Toggle tunneldigger and bandwidth limit
  DEPENDS:=gluon-config-mode-core-virtual +gluon-mesh-vpn-tunneldigger
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-tunneldigger,i18n)
endef

define Package/gluon-config-mode-tunneldigger/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-tunneldigger,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-tunneldigger))
