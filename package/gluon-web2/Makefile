include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web2

PKG_INSTALL:=1

include ../gluon.mk

define Package/gluon-web2
  TITLE:=Gluon Web rewritten with Preact and Parcel
  DEPENDS:=+gluon-web
endef

$(eval $(call BuildPackageGluon,gluon-web2))
