include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-mesh-vpn-fastd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-luci-mesh-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci module to enable and disable encryption for the mesh VPN
  DEPENDS:=+gluon-luci-admin +gluon-mesh-vpn-fastd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-mesh-vpn-fastd,i18n)
endef

define Package/gluon-luci-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-mesh-vpn-fastd,$(1))
endef

define Package/gluon-luci-mesh-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-luci-mesh-vpn-fastd))
