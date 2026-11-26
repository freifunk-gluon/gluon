include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv

include ../gluon.mk

define Package/gluon-mesh-batman-adv-15
  PROVIDES:=gluon-mesh-batman-adv
  TITLE:=Support for batman-adv meshing (compat level 15)
  DEPENDS+= \
	+gluon-mesh-batman-adv-common
endef

$(eval $(call BuildPackageGluon,gluon-mesh-batman-adv-15))
