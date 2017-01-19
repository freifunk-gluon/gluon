include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core

GLUON_VERSION = $(shell git describe --always --dirty=+ 2>/dev/null || echo unknown)
PKG_VERSION:=$(if $(DUMP),x,$(GLUON_VERSION))


PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk


define Package/gluon-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Base files of Gluon
  DEPENDS:=+gluon-site +libgluonutil +lua-platform-info +lua-simple-uci +lua-hash +luci-lib-jsonc +luci-lib-nixio +odhcp6c +firewall +pretty-hostname
endef

define Package/gluon-core/description
	Gluon community wifi mesh firmware framework: core
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-core/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon
	echo '$(GLUON_VERSION)' > $(1)/lib/gluon/gluon-version
endef

define Package/gluon-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-core))
