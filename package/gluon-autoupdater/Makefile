include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=4
PKG_RELEASE:=$(GLUON_BRANCH)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := respondd

include $(GLUONDIR)/include/package.mk

define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +libgluonutil +micrond +autoupdater
  TITLE:=Automatically update firmware
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/autoupdater.so

	if [ '$(GLUON_BRANCH)' ]; then \
		$(INSTALL_DIR) $(1)/lib/gluon/autoupdater; \
		echo '$(GLUON_BRANCH)' > $(1)/lib/gluon/autoupdater/default_branch; \
	fi
endef

define Package/gluon-autoupdater/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-autoupdater))
