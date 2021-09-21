include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-lock-password

include ../gluon.mk

define Package/gluon-lock-password
  TITLE:=Locks the root account by default
  DEPENDS:=+gluon-core
endef

define Package/gluon-lock-password/description
	This packages locks the root account by default.
endef

$(eval $(call BuildPackageGluon,gluon-lock-password))
