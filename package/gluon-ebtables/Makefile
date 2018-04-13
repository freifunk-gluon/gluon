include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ebtables
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_CONFIG_DEPENDS := CONFIG_GLUON_SPECIALIZE_KERNEL

include ../gluon.mk

define Package/gluon-ebtables
  TITLE:=Ebtables support
  DEPENDS:=+gluon-core +ebtables-tiny \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_T_FILTER \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_T_NAT \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_ARP \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_IP \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_BRIDGE_EBT_IP6 \
	+!GLUON_SPECIALIZE_KERNEL:kmod-ebtables \
	+!GLUON_SPECIALIZE_KERNEL:kmod-ebtables-ipv4 \
	+!GLUON_SPECIALIZE_KERNEL:kmod-ebtables-ipv6
endef

define Package/gluon-ebtables/description
	Gluon community wifi mesh firmware framework: ebtables support
endef

$(eval $(call BuildPackageGluon,gluon-ebtables))
