include $(TOPDIR)/rules.mk

PKG_NAME:=ffnw-hoodselector
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := lua/host luci-base/host respondd

include $(GLUONDIR)/include/package.mk


define Package/ffnw-hoodselector
  SECTION:=networke
  CATEGORY:=Freifunk Nordwest
  TITLE:=Select the hoods depending on the geo coordinate
  DEPENDS:=+ffnw-hoods +luci-lib-jsonc gluon-mesh-batman-adv-15 +gluon-mesh-vpn-fastd +respondd
endef

define Package/ffnw-hoodselector/description
	Select the hoods depending on the geo coordinates
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/ffnw-hoodselector/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/luadest/hoodselector $(1)/usr/sbin/hoodselector
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/hoodselector.so
endef

$(eval $(call BuildPackage,ffnw-hoodselector))
