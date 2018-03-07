include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core

GLUON_VERSION = $(shell git describe --always --dirty=+ 2>/dev/null || echo unknown)
PKG_VERSION:=$(if $(DUMP),x,$(GLUON_VERSION))

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gluon-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Base files of Gluon
  DEPENDS:= \
	+gluon-site +libgluonutil +libiwinfo-lua +lua-platform-info +lua-simple-uci +lua-hash +lua-jsonc \
	+luci-lib-nixio +vxlan +odhcp6c +firewall +pretty-hostname
endef

define Package/gluon-core/description
	Gluon community wifi mesh firmware framework: core
endef

define Build/Compile
	$(call Build/Compile/Default,all)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-core/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/

	$(INSTALL_DIR) $(1)/lib/gluon
	echo '$(GLUON_VERSION)' > $(1)/lib/gluon/gluon-version
endef

define Package/gluon-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-core))
