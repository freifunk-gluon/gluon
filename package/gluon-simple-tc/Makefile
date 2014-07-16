include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-simple-tc
PKG_VERSION:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-simple-tc
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Bandwidth limit support
  DEPENDS:=+gluon-core +tc +kmod-sched
endef

define Package/gluon-simple-tc/description
	Gluon community wifi mesh firmware framework: tc support
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-simple-tc/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-simple-tc/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-simple-tc))
