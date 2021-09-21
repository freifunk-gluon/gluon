include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alfred

include ../gluon.mk

define Package/gluon-alfred
  DEPENDS:=+gluon-core +gluon-respondd +gluon-neighbour-info gluon-mesh-batman-adv +micrond +alfred
  TITLE:=Configure alfred
endef

$(eval $(call BuildPackageGluon,gluon-alfred))
