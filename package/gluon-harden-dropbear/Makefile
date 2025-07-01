include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-harden-dropbear

include ../gluon.mk

define Package/gluon-harden-dropbear
  TITLE:=Reduces dropbears exposition
  DEPENDS:=+gluon-core +gluon-lock-password
endef

define Package/gluon-harden-dropbear/description
	This packages disables password access if root is locked and disables dropbear if no access is configured.
endef

$(eval $(call BuildPackageGluon,gluon-harden-dropbear))
