include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-debug
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk


define Package/gluon-debug
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Provides process runtime information to the network
  DEPENDS:=+libgluonutil +respondd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/gluon-debug/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/debug.so
endef

$(eval $(call BuildPackage,gluon-debug))
