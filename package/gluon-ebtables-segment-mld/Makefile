include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables-segment-mld
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ebtables-segment-mld
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Ebtables filters for IGMP/MLD packets
  DEPENDS:=+gluon-core +gluon-ebtables
endef

define Package/gluon-ebtables-segment-mld/description
	Gluon community wifi mesh firmware framework: Ebtables filters for
	IGMP/MLD packets

	These filters drop IGMP/MLD packets before they enter the mesh and
	filter any IGMP/MLD packets coming from the mesh.

	IGMP/MLD have the concept of a local, elected Querier. For more
	decentralization and increased robustness, the idea of this package is
	to split the IGMP/MLD domain a querier is responsible for, allowing to
	have a querier per node. The split IGMP/MLD domain will also reduce
	overhead for this packet type, increasing scalability.

	Beware of the consequences of using this package though: You might need
	to explicitly, manually mark ports on snooping switches leading towards
	your mesh node as multicast router ports for now (Multicast Router
	Discovery, MRD, not implemented yet).
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ebtables-segment-mld/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ebtables-segment-mld))
