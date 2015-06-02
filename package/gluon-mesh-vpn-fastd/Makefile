include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-mesh-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting batman-adv meshes via fastd
  DEPENDS:=+gluon-core gluon-mesh-batman-adv +gluon-wan-dnsmasq +fastd +iptables-mod-extra
endef

define Package/gluon-mesh-vpn-fastd/description
	Gluon community wifi mesh firmware framework: fastd support
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-mesh-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-fastd))
