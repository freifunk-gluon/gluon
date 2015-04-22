include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-legacy
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-legacy
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Legacy update scripts
  DEPENDS:=+gluon-core
endef

define Package/gluon-legacy/description
	Gluon community wifi mesh firmware framework: legacy update scripts
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-legacy/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-legacy/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-legacy))
