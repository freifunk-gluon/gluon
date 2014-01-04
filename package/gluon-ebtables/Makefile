include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ebtables
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Ebtables support
  DEPENDS:=+gluon-core +ebtables +kmod-ebtables-ipv4 +kmod-ebtables-ipv6 +kmod-ipt-core
endef

define Package/gluon-ebtables/description
	Gluon community wifi mesh firmware framework: ebtables support
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ebtables/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ebtables))
