include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-announced
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-announced
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Provides node information to the network
  DEPENDS:=+gluon-announce +respondd +lua-deflate
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-announced/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-announced))
