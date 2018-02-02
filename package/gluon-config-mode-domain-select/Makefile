include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-domain-select
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-domain-select
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=UI for changing the node-config
  DEPENDS:=+gluon-config-mode-core @GLUON_MULTIDOMAIN
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-domain-select,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-config-mode-domain-select/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-domain-select,$(1))
endef

define Package/gluon-config-domain-select/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode-domain-select))
