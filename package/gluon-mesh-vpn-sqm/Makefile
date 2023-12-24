include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-sqm

include ../gluon.mk

define Package/gluon-mesh-vpn-sqm
  TITLE:=Adds support for SQM with CAKE on VPN links
  DEPENDS:= +gluon-mesh-vpn-core +sqm-scripts
endef

define Package/gluon-mesh-vpn-sqm/install
	$(Gluon/Build/Install)
	$(INSTALL_DIR) $(1)/lib/gluon/mesh-vpn
	touch $(1)/lib/gluon/mesh-vpn/sqm
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-sqm))
