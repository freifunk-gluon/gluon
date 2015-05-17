include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-p2p-vpn-fastd
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-p2p-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting batman-adv meshes via p2p fastd
  DEPENDS:=+gluon-core +gluon-mesh-vpn-fastd
endef

define Package/gluon-p2p-vpn-fastd/description
	Gluon community wifi mesh firmware framework: fastd support for p2p connections
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-p2p-vpn-fastd/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-p2p-vpn-fastd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-p2p-vpn-fastd))
