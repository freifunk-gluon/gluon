include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-alt-esc-provider
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/gluon-alt-esc-provider
  DEPENDS:=+gluon-web-admin +ip6tables-mod-nat
  TITLE:=Gluon Alternative Exit Service Collaborator - Provider
endef

$(eval $(call BuildPackageGluon,gluon-alt-esc-provider))
