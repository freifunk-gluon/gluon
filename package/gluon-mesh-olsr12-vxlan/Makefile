include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-olsr12-vxlan
PKG_VERSION=1

include ../gluon.mk

define Package/gluon-mesh-olsr12-vxlan
  TITLE:=olsrd v1 to v2 migration fallback vpn
  DEPENDS:= +gluon-mesh-olsrd +vxlan
endef

$(eval $(call BuildPackageGluon,gluon-mesh-olsr12-vxlan))
