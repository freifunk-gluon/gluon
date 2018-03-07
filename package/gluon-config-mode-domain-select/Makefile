include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-domain-select
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-domain-select
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=UI for changing the node-config
  DEPENDS:=+gluon-config-mode-core @GLUON_MULTIDOMAIN
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-config-mode-domain-select/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

define Package/gluon-config-domain-select/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode-domain-select))
