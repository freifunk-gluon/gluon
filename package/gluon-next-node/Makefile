include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-next-node
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-next-node
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Next-node anycast address
  DEPENDS:=+gluon-core +gluon-ebtables +gluon-mesh-batman-adv +ip +kmod-macvlan
endef

define Package/gluon-next-node/description
	Gluon community wifi mesh firmware framework: next-node anycast address
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-next-node/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-next-node))
