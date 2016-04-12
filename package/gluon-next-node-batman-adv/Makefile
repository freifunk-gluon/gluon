include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-next-node-batman-adv
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-next-node-batman-adv
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Next-node anycast address ebtables filter for batman-adv
  DEPENDS:=+gluon-core +gluon-ebtables +gluon-next-node +gluon-mesh-batman-adv +kmod-macvlan
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-next-node-batman-adv/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-next-node-batman-adv))
