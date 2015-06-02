include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-cron
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-cron
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Cron support
  DEPENDS:=+gluon-core
endef

define Package/gluon-cron/description
	Gluon community wifi mesh firmware framework: cron support
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

define Package/gluon-cron/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-crond $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gluon-cron))
