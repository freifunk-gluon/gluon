include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-core

include ../gluon.mk

define Package/gluon-mesh-vpn-core
  TITLE:=Basic support for connecting meshes via VPN tunnels
  DEPENDS:=+gluon-core +gluon-wan-dnsmasq +iptables-zz-legacy +iptables-mod-extra
  USERID:=:gluon-mesh-vpn=800
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-core))
