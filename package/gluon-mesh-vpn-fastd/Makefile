include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-fastd
PKG_VERSION:=1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-mesh-vpn-fastd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for connecting batman-adv meshes via fastd
  DEPENDS:=+gluon-core +gluon-mesh-batman-adv +fastd
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
	$(GLUON_CONFIGURE) fastd.pl > $(PKG_BUILD_DIR)/fastd.sh
endef

define Package/gluon-mesh-vpn-fastd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/upgrade/mesh-vpn-fastd/invariant
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fastd.sh $(1)/lib/gluon/upgrade/mesh-vpn-fastd/invariant/010-mesh-vpn-fastd
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-fastd))
