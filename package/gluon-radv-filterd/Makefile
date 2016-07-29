include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radv-filterd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-radv-filterd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Filter IPv6 router advertisements
  DEPENDS:=+gluon-ebtables
endef

define Package/gluon-radv-filterd/description
	Gluon community wifi mesh firmware framework: filter IPv6 router advertisements
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

define Package/gluon-radv-filterd/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-radv-filterd $(1)/usr/sbin/
endef

define Package/gluon-radv-filterd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-radv-filterd))
