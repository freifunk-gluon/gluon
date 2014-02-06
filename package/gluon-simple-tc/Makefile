include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-simple-tc
PKG_VERSION:=1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-simple-tc
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Bandwidth limit support
  DEPENDS:=+gluon-core +tc +kmod-sched
endef

define Package/gluon-simple-tc/description
	Gluon community wifi mesh firmware framework: tc support
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-simple-tc/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon/upgrade/simple-tc/invariant
	$(GLUON_CONFIGURE) invariant.pl > $(1)/lib/gluon/upgrade/simple-tc/invariant/010-site-defaults
	chmod +x $(1)/lib/gluon/upgrade/simple-tc/invariant/010-site-defaults
endef

$(eval $(call BuildPackage,gluon-simple-tc))
