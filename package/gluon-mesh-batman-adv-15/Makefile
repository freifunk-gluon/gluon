include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv-15
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk


define Package/gluon-mesh-batman-adv-15
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for batman-adv meshing (compat level 15)
  DEPENDS:=+gluon-mesh-batman-adv-core +kmod-batman-adv +batctl
  PROVIDES:=gluon-mesh-batman-adv
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-mesh-batman-adv-15/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-mesh-batman-adv-15))
