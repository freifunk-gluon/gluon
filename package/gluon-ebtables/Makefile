include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables

include ../gluon.mk

define Package/gluon-ebtables
  TITLE:=Ebtables support
  DEPENDS:=+gluon-core +ebtables-nft
endef

define Package/gluon-ebtables/description
	Gluon community wifi mesh firmware framework: ebtables support
endef

$(eval $(call BuildPackageGluon,gluon-ebtables))
