include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core
PKG_VERSION:=1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

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
endef

$(eval $(call BuildPackage,gluon-core))
