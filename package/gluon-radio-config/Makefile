include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radio-config
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-radio-config
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Basic radio config (regdom, channel, htmode)
  DEPENDS:=+gluon-core
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-radio-config/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-radio-config))
