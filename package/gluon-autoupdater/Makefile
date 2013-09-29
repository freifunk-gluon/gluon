include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=0.3.2.99
PKG_RELEASE:=0.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+ecdsautils +gluon-cron
  TITLE:=Automatically update firmware
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/
	chmod +x $(1)/usr/sbin/autoupdate
endef

$(eval $(call BuildPackage,gluon-autoupdater))
