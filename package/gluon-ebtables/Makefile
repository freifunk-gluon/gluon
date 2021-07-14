include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-ebtables
  TITLE:=Ebtables support
  DEPENDS:=+gluon-core +ebtables-tiny \
	+kmod-ebtables +kmod-ebtables-ipv4 +kmod-ebtables-ipv6
endef

define Package/gluon-ebtables/description
	Gluon community wifi mesh firmware framework: ebtables support
endef

$(eval $(call BuildPackageGluon,gluon-ebtables))
