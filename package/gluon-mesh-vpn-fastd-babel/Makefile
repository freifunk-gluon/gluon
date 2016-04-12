include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd-babel
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-mesh-vpn-fastd-babel
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting babel meshes via fastd
  DEPENDS:=+gluon-core +libgluonutil +babeld +gluon-wan-dnsmasq +fastd +iptables-mod-extra +simple-tc
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/gluon-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/

endef

define Package/gluon-mesh-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-fastd))
