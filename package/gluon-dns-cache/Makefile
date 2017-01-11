include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-dns-config
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-dns-config
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Use Node as DNS cache, configure using site.conf
  DEPENDS:=+gluon-core
endef

define Package/gluon-legacy/description
	Use Node as DNS cache, configure using site.conf
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-dns-config/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-dns-config))

