include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := respondd

include $(GLUONDIR)/include/package.mk


define Package/gluon-mesh-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting batman-adv meshes via fastd
  DEPENDS:=+gluon-core +libgluonutil gluon-mesh-batman-adv +gluon-wan-dnsmasq +fastd +iptables +iptables-mod-extra +simple-tc
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/mesh-vpn-fastd.so
endef

define Package/gluon-mesh-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-fastd))
