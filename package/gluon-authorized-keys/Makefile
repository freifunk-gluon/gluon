include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-authorized-keys
PKG_VERSION:=2

include ../gluon.mk

define Package/gluon-authorized-keys
  TITLE:=Fill /etc/dropbear/authorized_keys from site.conf
  DEPENDS:=+gluon-core +gluon-lock-password
endef

$(eval $(call BuildPackageGluon,gluon-authorized-keys))
