include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radvd
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk


define Package/gluon-radvd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Advertise an IPv6 prefix from the node
  DEPENDS:=+gluon-core +uradvd
endef

define Package/gluon-radvd/description
	Gluon community wifi mesh firmware framework: Advertise an IPv6 prefix from the node
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-radvd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

$(eval $(call BuildPackage,gluon-radvd))
