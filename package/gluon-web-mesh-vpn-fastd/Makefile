include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-mesh-vpn-fastd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-web-mesh-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=gluon-web module to enable and disable encryption for the mesh VPN
  DEPENDS:=+gluon-web-admin +gluon-mesh-vpn-fastd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-mesh-vpn-fastd,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-web-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-mesh-vpn-fastd,$(1))
endef

define Package/gluon-web-mesh-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-web-mesh-vpn-fastd))
