include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-wifi-mesh-macfilter
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-wifi-block-station
  SECTION:=gluon
  CATEGORY:=GLUON
  TITLE:=WiFi - block/open 802.11s-mesh stations
  DEPENDS:=+iw +uci
endef

define Package/gluon-wifi-mesh-macfilter/description
	Setting plink_action [block|open], when 802.11s mesh-interface comes up.
	Define filterpolicy in uci wireless.<wifi-iface>.macfilter=[disable|deny|allow], deny sets plink_action block, allow sets plink_action open.
	List MAC adresses (divided by spaces) in uci wireless.<wifi-iface>.maclist.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-wifi-mesh-macfilter/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-wifi-mesh-macfilter))
