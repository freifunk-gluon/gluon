include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=0.3.2.99
PKG_RELEASE:=0.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+ecdsautils +gluon-cron +gluon-release
  TITLE:=Automatically update firmware
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(GLUON_CONFIGURE) autoupdater.pl > $(PKG_BUILD_DIR)/autoupdater.sh
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/upgrade/autoupdater/initial
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/autoupdater.sh $(1)/lib/gluon/upgrade/autoupdater/initial/010-autoupdater
endef

$(eval $(call BuildPackage,gluon-autoupdater))
