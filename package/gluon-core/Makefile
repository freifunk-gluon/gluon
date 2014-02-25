include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core
PKG_VERSION:=1
PKG_RELEASE:=$(GLUON_VERSION).$(GLUON_SITE_CODE)-$(GLUON_RELEASE).$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Base files of Gluon
  DEPENDS:=+odhcp6c
endef

define Package/gluon-core/description
	Gluon community wifi mesh firmware framework: core
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-core/install
	$(CP) ./files/* $(1)/
	$(GLUON_GENERATE) ./generate/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon
	echo "$(GLUON_VERSION)" > $(1)/lib/gluon/version
	echo "$(GLUON_RELEASE)" > $(1)/lib/gluon/release
endef

$(eval $(call BuildPackage,gluon-core))
