include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-contact-info
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-config-mode-contact-info
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Set a custom string that will be distributed in the mesh.
  DEPENDS:=+gluon-config-mode-core +gluon-node-info
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode-contact-info/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-config-mode-contact-info))
