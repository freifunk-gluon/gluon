include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radvd-babel
PKG_VERSION:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-radvd-babel
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Advertise an IPv6 prefix from the node
  DEPENDS:=+gluon-core +gluon-mesh-babel +uradvd
endef

define Package/gluon-radvd-babel/description
	Gluon community wifi mesh firmware framework: Advertise an IPv6 prefix from the node
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-radvd-babel/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-radvd-babel))
