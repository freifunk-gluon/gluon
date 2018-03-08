include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-lock-password
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-lock-password
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Locks the root account by default
  DEPENDS:=+gluon-core
endef

define Package/gluon-lock-password/description
	This packages locks the root account by default.
endef

$(eval $(call BuildPackageGluon,gluon-lock-password))
