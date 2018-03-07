include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radv-filterd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DEPENDS := respondd

include ../gluon.mk

define Package/gluon-radv-filterd
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Filter IPv6 router advertisements
  DEPENDS:=+gluon-ebtables +libgluonutil +libbatadv +libnl-tiny
endef

MAKE_VARS += \
        LIBNL_NAME="libnl-tiny" \
        LIBNL_GENL_NAME="libnl-tiny"

define Package/gluon-radv-filterd/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-radv-filterd $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/radv-filterd.so
endef

define Package/gluon-radv-filterd/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-radv-filterd))
