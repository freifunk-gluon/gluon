include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-filter-ra-dhcp
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ebtables-filter-ra-dhcp
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Ebtables filters for Router Advertisement and DHCP packets
  DEPENDS:=+gluon-core +gluon-ebtables
endef

define Package/gluon-ebtables-filter-ra-dhcp/description
	Gluon community wifi mesh firmware framework: Ebtables filters for Router Advertisement and DHCP packets

	These filters ensure that RA and DHCP packets are only forwarded from the mesh into the
	client network, and not vice-versa.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ebtables-filter-ra-dhcp/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ebtables-filter-ra-dhcp))
