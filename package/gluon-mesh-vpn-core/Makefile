include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-core
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-vpn-core
  TITLE:=Basic support for connecting meshes via VPN tunnels
  DEPENDS:=+gluon-core +gluon-wan-dnsmasq +iptables +iptables-mod-extra +simple-tc \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NETFILTER_XT_MATCH_ADDRTYPE \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NETFILTER_XT_MATCH_OWNER \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NETFILTER_XT_MATCH_PKTTYPE \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NETFILTER_XT_MATCH_QUOTA \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NET_CLS_BASIC \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NET_ACT_POLICE \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NET_SCH_TBF \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_NET_SCH_INGRESS
  USERID:=:gluon-mesh-vpn=800
endef

$(eval $(call BuildPackageGluon,gluon-mesh-vpn-core))
