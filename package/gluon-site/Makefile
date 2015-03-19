include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-site
PKG_VERSION:=$(GLUON_SITE_CODE)
PKG_RELEASE:=0.$(GLUON_RELEASE)

PKG_FILE_DEPENDS := $(GLUON_SITEDIR)/

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-site
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Site-specific config files of Gluon
endef

define Package/gluon-site/description
	Gluon community wifi mesh firmware framework: site configuration
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-site/install
	$(INSTALL_DIR) $(1)/lib/gluon
	$(CP) $(GLUON_SITEDIR)/site.conf $(1)/lib/gluon/site.conf
	echo "$(GLUON_RELEASE)" > $(1)/lib/gluon/release
endef

$(eval $(call BuildPackage,gluon-site))
