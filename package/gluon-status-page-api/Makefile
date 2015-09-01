include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-status-page-api
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-status-page-api
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=API for gluon-status-page
  DEPENDS:=+gluon-core +uhttpd +gluon-neighbour-info +gluon-announced +libiwinfo-lua +luci-lib-jsonc
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-status-page-api/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-status-page-api))
