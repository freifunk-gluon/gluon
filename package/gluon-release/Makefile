include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-release
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-release
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=A file containing the current release
  DEPENDS:=+gluon-core
endef

define Package/gluon-release/description
	This packages creates /lib/gluon/release.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-release/install
	$(GLUON_GENERATE) ./generate/* $(1)/
endef

$(eval $(call BuildPackage,gluon-release))
