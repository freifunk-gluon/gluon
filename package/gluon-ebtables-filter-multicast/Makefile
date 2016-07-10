include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-filter-multicast
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk


define Package/gluon-ebtables-filter-multicast
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Ebtables filters for multicast packets
  DEPENDS:=+gluon-core +gluon-ebtables
endef

define Package/gluon-ebtables-filter-multicast/description
	Gluon community wifi mesh firmware framework: Ebtables filters for multicast packets

	These filters drop non-essential multicast traffic before it enters the mesh.

	Allowed protocols are: DHCP, DHCPv6, ARP, ICMP, ICMPv6, BitTorrent local peer discovery, BABEL and OSPF
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ebtables-filter-multicast/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ebtables-filter-multicast))
