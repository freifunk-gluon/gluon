include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-respondd
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-respondd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Provides node information to the network
  DEPENDS:=+gluon-core +libplatforminfo +libgluonutil +libuci +ubus +respondd
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-respondd/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/respondd.so
endef

$(eval $(call BuildPackage,gluon-respondd))
