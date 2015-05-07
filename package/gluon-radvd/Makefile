include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radvd
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-radvd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Advertise an IPv6 prefix from the node
  DEPENDS:=+gluon-core +gluon-ebtables +gluon-mesh-batman-adv +librt
endef

define Package/gluon-radvd/description
	Gluon community wifi mesh firmware framework: Advertise an IPv6 prefix from the node
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/gluon-radvd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-radvd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gluon-radvd))
