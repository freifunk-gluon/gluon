include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-node-info
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-node-info
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Add /etc/config/gluon-node-info to uci
  DEPENDS:=+gluon-core
endef

define Package/gluon-node-info/description
	This packages creates /etc/config/gluon-node-info.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-node-info/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-node-info))
