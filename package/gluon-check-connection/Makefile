include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-check-connection
PKG_VERSION:=1

include ../gluon.mk

define Package/$(PKG_NAME)
  TITLE:=Checks if a node can ping definable targets
  DEPENDS:=+gluon-core +micrond @GLUON_MULTIDOMAIN
endef

define Package/$(PKG_NAME)/description
  Script to check if there is a connection to any gateway and also if there is
  a connection to the global internet. This script is called once every minute
  by ``micrond``. It will trigger scripts which will be executed if a
  connection state changes or after a definable interval after which
  connections checks have been performed.
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
