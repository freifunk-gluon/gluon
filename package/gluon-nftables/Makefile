include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-nftables

include ../gluon.mk

define Package/gluon-nftables
  TITLE:=Nftables support
  DEPENDS:=+nftables-json
endef

define Package/gluon-nftables/description
	Gluon community wifi mesh firmware framework: Nftables support
endef

$(eval $(call BuildPackageGluon,gluon-nftables))
