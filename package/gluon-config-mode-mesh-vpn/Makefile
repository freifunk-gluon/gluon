include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-mesh-vpn
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-config-mode-mesh-vpn
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Toggle mesh-vpn and bandwidth limit
  DEPENDS:=+gluon-config-mode-core +gluon-mesh-vpn-fastd +gluon-simple-tc
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode-mesh-vpn/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-config-mode-mesh-vpn/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode-mesh-vpn))
