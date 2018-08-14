include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-contact-info
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-contact-info
  TITLE:=Allows the user to provide contact information to be distributed in the mesh
  DEPENDS:=+gluon-config-mode-core +gluon-node-info
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-contact-info))
