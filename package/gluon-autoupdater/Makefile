include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

PKG_CONFIG_DEPENDS := CONFIG_GLUON_BRANCH
PKG_BUILD_DEPENDS := respondd


include ../gluon.mk


define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +libgluonutil +micrond +autoupdater
  TITLE:=Automatically update firmware
endef

define Package/gluon-autoupdater/config
config GLUON_BRANCH
	string "Gluon autoupdater branch"
	depends on PACKAGE_gluon-autoupdater
	default ""
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/autoupdater.so

ifneq ($(CONFIG_GLUON_BRANCH),"")
	$(INSTALL_DIR) $(1)/lib/gluon/autoupdater
	echo '$(call qstrip,$(CONFIG_GLUON_BRANCH))' > $(1)/lib/gluon/autoupdater/default_branch
endif
endef

define Package/gluon-autoupdater/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-autoupdater))
