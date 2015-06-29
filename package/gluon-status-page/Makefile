include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-status-page
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Adds a status page showing information about the node.
  DEPENDS:=+gluon-core +uhttpd +gluon-neighbour-info +gluon-announce +libiwinfo-lua
endef

define Package/gluon-status-page/description
	Adds a status page showing information about the node.
	Especially useful in combination with the next-node feature.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-status-page/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-status-page))
