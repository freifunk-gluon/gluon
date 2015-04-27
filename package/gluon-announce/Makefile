include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-announce
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-announce
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +luci-lib-json +lua-ethtool-stats
  TITLE:=Lua scripts announcing various information
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-announce/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-announce))
