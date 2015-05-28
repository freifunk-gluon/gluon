include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv-core
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-mesh-batman-adv-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Support for batman-adv meshing (core)
  DEPENDS:=+gluon-core +firewall +kmod-ipt-nathelper +libiwinfo-lua
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-mesh-batman-adv-core/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-mesh-batman-adv-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef


$(eval $(call BuildPackage,gluon-mesh-batman-adv-core))
