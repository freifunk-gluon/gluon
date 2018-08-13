include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-hoodselector

GLUON_VERSION = 3
PKG_VERSION:=2

include ../gluon.mk

define Package/gluon-hoodselector
  TITLE:=Automatically sortes nodes into network hoods.
  DEPENDS:=+gluon-site +gluon-mesh-batman-adv-15 +micrond +libjson-c +luaposix +luabitop @GLUON_MULTIDOMAIN
  CONFLICTS:=+gluon-config-mode-domain-select
endef

define Package/gluon-hoodselector/description
  This is the hoodselector. The hoodselector is one of the main components for
  splitting a layer 2 mesh network into seperated network segments (hoods).
  The job of the hoodselector is to automatically detect in which hood
  the node is located based on geo settings or by scanning its environment.
  Based on this information the hoodselector should select a hood from a
  list of known hoods (hoodlist) and adjust VPN, wireless and mesh on lan
  configuration based on the settings given for the selected hood.
endef

$(eval $(call BuildPackageGluon,gluon-hoodselector))
