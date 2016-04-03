include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radv-priorityd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-radv-priorityd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Prioritize router advertisements
  DEPENDS:=+gluon-core +kmod-ipt-nfqueue +libnetfilter-queue +kmod-ipt-extra +iptables-mod-nfqueue
endef

define Package/gluon-radv-priorityd/description
	Gluon community wifi mesh firmware framework: prioritize router advertisements
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

define Package/gluon-radv-priorityd/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-radv-priorityd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gluon-radv-priorityd))
