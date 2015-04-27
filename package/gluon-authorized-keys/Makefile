include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-authorized-keys
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-authorized-keys
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Fill /etc/dropbear/authorized_keys from site.conf
  DEPENDS:=+gluon-core
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-authorized-keys/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-authorized-keys/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-authorized-keys))
