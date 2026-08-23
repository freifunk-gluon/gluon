include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall-clamp-mss-to-pmtu

include ../gluon.mk

define Package/$(PKG_NAME)
  TITLE:=Clamp the TCP MSS to the PMTU on mesh VPN interfaces (IPv6)
  DEPENDS:=+gluon-firewall
endef

define Package/$(PKG_NAME)/description
	Package working around icmp blackholes in the internet.
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
