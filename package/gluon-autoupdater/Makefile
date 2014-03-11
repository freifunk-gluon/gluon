include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=0.1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)$(if $(GLUON_BRANCH),.$(GLUON_BRANCH))

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +gluon-cron +opkg +ecdsautils +!BUSYBOX_CONFIG_SHA512SUM:coreutils-sha512sum
  TITLE:=Automatically update firmware
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon/upgrade/autoupdater/invariant
	GLUON_BRANCH='$(GLUON_BRANCH)' $(GLUON_CONFIGURE) invariant.pl > $(1)/lib/gluon/upgrade/autoupdater/invariant/010-autoupdater
	chmod +x $(1)/lib/gluon/upgrade/autoupdater/invariant/010-autoupdater
endef

$(eval $(call BuildPackage,gluon-autoupdater))
