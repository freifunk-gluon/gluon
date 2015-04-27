include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-hostname
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-hostname
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Set the hostname
  DEPENDS:=gluon-config-mode-core-virtual
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-hostname,i18n)
endef

define Package/gluon-config-mode-hostname/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-hostname,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-hostname))
