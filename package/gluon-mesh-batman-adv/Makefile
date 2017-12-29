include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := respondd

include ../gluon.mk


define Package/gluon-mesh-batman-adv/common
  SECTION:=gluon
  CATEGORY:=Gluon
  PROVIDES:=gluon-mesh-batman-adv
  DEPENDS:=+gluon-core +libgluonutil +gluon-client-bridge +gluon-ebtables +firewall +libiwinfo +kmod-dummy +libnl-tiny +libbatadv +libjson-c
endef

define Package/gluon-mesh-batman-adv-14
$(Package/gluon-mesh-batman-adv/common)
  TITLE:=Support for batman-adv meshing (compat level 14)
  CONFLICTS:=gluon-mesh-batman-adv-15
  DEPENDS+=+kmod-batman-adv-legacy
endef

define Package/gluon-mesh-batman-adv-15
$(Package/gluon-mesh-batman-adv/common)
  TITLE:=Support for batman-adv meshing (compat level 15)
  DEPENDS+=+kmod-batman-adv +batctl
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-mesh-batman-adv/common/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neighbours-batadv $(1)/lib/gluon/status-page/providers/
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/mesh-batman-adv.so

	$(INSTALL_DIR) $(1)/lib/gluon/mesh-batman-adv
endef

define Package/gluon-mesh-batman-adv-14/install
$(Package/gluon-mesh-batman-adv/common/install)
	echo 14 > $(1)/lib/gluon/mesh-batman-adv/compat
endef

define Package/gluon-mesh-batman-adv-15/install
$(Package/gluon-mesh-batman-adv/common/install)
	echo 15 > $(1)/lib/gluon/mesh-batman-adv/compat
endef

define Package/gluon-mesh-batman-adv/common/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef
Package/gluon-mesh-batman-adv-14/postinst := $(Package/gluon-mesh-batman-adv/common/postinst)
Package/gluon-mesh-batman-adv-15/postinst := $(Package/gluon-mesh-batman-adv/common/postinst)


$(eval $(call BuildPackage,gluon-mesh-batman-adv-14))
$(eval $(call BuildPackage,gluon-mesh-batman-adv-15))
