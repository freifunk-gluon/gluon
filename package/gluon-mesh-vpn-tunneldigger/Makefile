include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-tunneldigger
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

define Package/gluon-mesh-vpn-tunneldigger
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting meshes via tunneltigger/l2tpv3 pseudowire
  DEPENDS:=+gluon-core +gluon-wan-dnsmasq +tunneldigger +iptables +iptables-mod-extra +simple-tc
endef

define Package/gluon-mesh-vpn-tunneldigger/description
	Gluon community wifi mesh firmware framework: tunneldigger support
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-mesh-vpn-tunneldigger/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/	
endef

define Package/gluon-mesh-vpn-tunneldigger/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-tunneldigger))
