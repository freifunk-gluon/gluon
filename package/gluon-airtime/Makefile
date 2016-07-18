include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-airtime
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := respondd

include $(GLUONDIR)/include/package.mk

define Package/gluon-airtime
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Add airtime to respondd
  DEPENDS:=+respondd +libnl-tiny
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef


TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef


define Package/gluon-airtime/install
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/airtime.so
endef

$(eval $(call BuildPackage,gluon-airtime))
