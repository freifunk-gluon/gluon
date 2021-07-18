include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-state-online
PKG_VERSION:=1

include ../gluon.mk

define Package/$(PKG_NAME)
  TITLE:=Provides info about the routers online state
  DEPENDS:=+gluon-core +micrond
endef

define Package/$(PKG_NAME)/description
  This script runs several checks and provides the results as flags in `/var/gluon/state`.
  It is called by micron.d once every minute.
  A flag exists in case of its description being true and gets removed otherwise.
  The flags get opened regardless them being changed.

  Currently available flags:
    has_default_gw4
    has_default_gw6
      whether the router has a default route given the IP version
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
