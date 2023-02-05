include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-iptables-clamp-mss-to-pmtu

include ../gluon.mk

define Package/$(PKG_NAME)
  TITLE:=This will establish a firewall rule to clamp the mss to pmtu on the mesh-vpn interface when the connection is towards 64:ff9b::/96
endef

define Package/$(PKG_NAME)/description
	Package working around icmp blackholes in the internet.
endef

define Package/$(PKG_NAME)/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
