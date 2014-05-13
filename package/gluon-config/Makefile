include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config
PKG_VERSION:=$(GLUON_SITE_CODE)
PKG_RELEASE:=$(shell $(MD5SUM) $(GLUON_SITEDIR)/site.conf)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-config
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Site-specific config files of Gluon
endef

define Package/gluon-config/description
	Gluon community wifi mesh firmware framework: site configuration
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config/install
	$(INSTALL_DIR) $(1)/lib/gluon
	$(CP) $(GLUON_SITEDIR)/site.conf $(1)/lib/gluon/site.conf
endef

$(eval $(call BuildPackage,gluon-config))
