include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-announced
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-announced
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=announced support
  DEPENDS:=
endef

define Package/gluon-announced/description
	Gluon community wifi mesh firmware framework: announced support
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

define Package/gluon-announced/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-announced $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gluon-announced))
