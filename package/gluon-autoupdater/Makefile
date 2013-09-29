include $(TOPDIR)/rules.mk

PKG_NAME:=autoupdater
PKG_RELEASE:=0.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/autoupdater
  SECTION:=admin
  CATEGORY:=Administration
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

define Package/autoupdater/install
	$(CP) ./files/* $(1)/
	chmod +x $(1)/usr/sbin/autoupdate
endef

$(eval $(call BuildPackage,autoupdater))
