include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-hoodselector

GLUON_VERSION = 3
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

define Package/gluon-hoodselector
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Automatically sorte routers into network hoods.
  DEPENDS:=+gluon-site +gluon-mesh-batman-adv-15 @GLUON_MULTIDOMAIN
  CONFLICTS:=+gluon-config-mode-domain-select
endef

define Package/gluon-hoodselector/description
  This is the hoodselector. The hoodselector is one of the main components for
  splitting a layer 2 mesh network into seperated network segments (hoods).
  The job of the hoodselector is to automatically detect in which hood
  the router is located based on geo settings or by scanning its environment.
  Based on these informations the hoodselector should select a hood from a
  list of known hoods (hoodlist) and adjust vpn, wireless and mesh on lan
  configuration based on the settings given for the selected hood.
endef

$(eval $(call BuildPackageGluon,gluon-hoodselector))
