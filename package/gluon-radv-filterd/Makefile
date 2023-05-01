include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radv-filterd

include ../gluon.mk

define Package/gluon-radv-filterd
  TITLE:=Filter IPv6 router advertisements
  DEPENDS:=+gluon-nftables +libgluonutil +libbatadv +libnl-tiny
endef

MAKE_VARS += \
        LIBNL_NAME="libnl-tiny" \
        LIBNL_GENL_NAME="libnl-tiny"

define Package/gluon-radv-filterd/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gluon-radv-filterd $(1)/usr/sbin/
endef

$(eval $(call BuildPackageGluon,gluon-radv-filterd))
