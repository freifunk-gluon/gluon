include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-migrate-vpn
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-migrate-vpn
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Enables either fastd or tunneldigger if the opposite was active before upgrading
  DEPENDS:=+gluon-core
endef

define Package/gluon-migrate-vpn/description
	Gluon community wifi mesh firmware framework: VPN service migration script
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-migrate-vpn/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-migrate-vpn/postinst
endef

$(eval $(call BuildPackage,gluon-migrate-vpn))
