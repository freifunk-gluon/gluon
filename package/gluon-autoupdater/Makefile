include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=4
PKG_RELEASE:=$(GLUON_BRANCH)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/gluon-autoupdater
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +gluon-cron +autoupdater
  TITLE:=Automatically update firmware
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-autoupdater/install
	$(CP) ./files/* $(1)/

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
