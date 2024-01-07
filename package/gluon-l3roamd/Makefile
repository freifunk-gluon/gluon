include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-l3roamd

include ../gluon.mk

define Package/gluon-l3roamd
  TITLE:=Configure l3roamd for l3-mesh
  DEPENDS:=+gluon-core +gluon-mesh-layer3-common +l3roamd +uc
endef

$(eval $(call BuildPackageGluon,gluon-l3roamd))
