include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-nftables-multicast

include ../gluon.mk

define Package/gluon-nftables-multicast
  TITLE:=nftables multicast filtering
  DEPENDS:=+gluon-core +gluon-nftables
endef

define Package/gluon-nftables-multicast/description
	Gluon community wifi mesh firmware framework: nftables multicast filtering
endef

$(eval $(call BuildPackageGluon,gluon-nftables-multicast))
