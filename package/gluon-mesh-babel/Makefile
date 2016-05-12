include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-babel
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PROVIDES := gluon-radvd-provider
include $(GLUONDIR)/include/package.mk

define Package/gluon-mesh-babel
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Babel mesh
  DEPENDS:=+gluon-core +babeld
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-mesh-babel/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-mesh-babel/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-babel))
