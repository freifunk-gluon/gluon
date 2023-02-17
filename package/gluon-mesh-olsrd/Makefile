include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-olsrd
PKG_VERSION=1

include ../gluon.mk

define Package/gluon-mesh-olsrd
	TITLE:=olsrd mesh
	DEPENDS:= \
		+gluon-core \
		@IPV6 \
		+oonf-olsrd2 \
		+firewall \
		+gluon-mesh-layer3-common \
		+gluon-l3roamd
	PROVIDES:=gluon-mesh-provider
endef

$(eval $(call BuildPackageGluon,gluon-mesh-olsrd))
