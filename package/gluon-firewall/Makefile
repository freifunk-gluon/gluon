include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall

include ../gluon.mk

define Package/gluon-firewall
  TITLE:=nftables-based firewall rule framework
  DEPENDS:=+gluon-core +firewall4 +kmod-nft-bridge
endef

define Package/gluon-firewall/description
	Gluon community wifi mesh firmware framework: nftables firewall support

	Provides the loader that translates the rule snippets in
	/lib/gluon/nftables into a bridge-family nftables table and
	firewall4 includes.
endef

$(eval $(call BuildPackageGluon,gluon-firewall))
