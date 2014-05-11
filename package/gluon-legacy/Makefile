include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-legacy
PKG_VERSION:=1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-legacy
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Legacy update scripts
  DEPENDS:=+gluon-core
endef

define Package/gluon-legacy/description
	Gluon community wifi mesh firmware framework: legacy update scripts
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-legacy/install
	$(GLUON_GENERATE) ./generate/* $(1)/
endef

$(eval $(call BuildPackage,gluon-legacy))
