include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-node-role
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-luci-node-role
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-luci-admin +gluon-node-info
  TITLE:=UI for specifying node role
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-luci-node-role/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-luci-node-role/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-luci-node-role))
