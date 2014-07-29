include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-simple-tc
PKG_VERSION:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-simple-tc
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Bandwidth limit support
  DEPENDS:=+gluon-core +kmod-sched +libnl-tiny
endef

define Package/gluon-simple-tc/description
	Gluon community wifi mesh firmware framework: tc support
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

define Package/gluon-simple-tc/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-simple-tc $(1)/usr/sbin/
endef

define Package/gluon-simple-tc/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-simple-tc))
