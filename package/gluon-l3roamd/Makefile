include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-l3roamd
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-l3roamd
  TITLE:=Configure l3roamd for babel
  DEPENDS:=+gluon-core +l3roamd +uc
endef

$(eval $(call BuildPackageGluon,gluon-l3roamd))
