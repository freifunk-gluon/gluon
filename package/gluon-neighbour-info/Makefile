include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-neighbour-info
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-neighbour-info
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=neighbour-info
  DEPENDS:=
endef

define Package/gluon-neighbour-info/description
	Gluon community wifi mesh firmware framework: neighbour-info
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

define Package/gluon-neighbour-info/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-neighbour-info $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gluon-neighbour-info))
