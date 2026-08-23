include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall

include ../gluon.mk

define Package/gluon-firewall
  TITLE:=Ebtables support
  DEPENDS:=+gluon-core +ebtables-tiny \
	+kmod-ebtables +kmod-ebtables-ipv4 +kmod-ebtables-ipv6
endef

define Package/gluon-firewall/description
	Gluon community wifi mesh firmware framework: ebtables support
endef

$(eval $(call BuildPackageGluon,gluon-firewall))
