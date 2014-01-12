include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alfred-ffmap
PKG_VERSION:=0.1
PKG_RELEASE:=1.$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-alfred-ffmap
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-alfred +gluon-location
  TITLE:=Distribute data for ffmap via alfred
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-alfred-ffmap/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-alfred-ffmap))
