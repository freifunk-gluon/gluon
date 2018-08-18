include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-wireguard
PKG_VERSION:=3

include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-mesh-vpn-wireguard
  TITLE:=WireGuard Mesh VPN Support
  DEPENDS:=+gluon-core +gluon-mesh-vpn-core +kmod-wireguard +jsonfilter +wireguard-tools +micrond +@BUSYBOX_CONFIG_TIMEOUT
endef

define Package/gluon-mesh-vpn-wireguard/description
  Support layer 3 mesh-vpn connection using wireguard. This can be used by mesh-protocols working on OSI layer 3.
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-wireguard))
