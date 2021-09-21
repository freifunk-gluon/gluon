include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-radvd

include ../gluon.mk

define Package/gluon-radvd
  TITLE:=Advertise an IPv6 prefix from the node
  DEPENDS:=+gluon-core +uradvd
endef

define Package/gluon-radvd/description
	Gluon community wifi mesh firmware framework: Advertise an IPv6 prefix from the node
endef

$(eval $(call BuildPackageGluon,gluon-radvd))
