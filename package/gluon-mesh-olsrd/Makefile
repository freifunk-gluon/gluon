include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-olsrd
PKG_VERSION=1

include ../gluon.mk

define Package/gluon-mesh-olsrd
  TITLE:=olsrd mesh
  DEPENDS:= \
		+gluon-core \
		+kmod-macvlan \
		@IPV6 \
		+oonf-olsrd2 \
		+firewall \
		+ip-full \
		+gluon-mmfd \
		+gluon-l3roamd \
		+gluon-radvd \
		+lua-jsonc
  PROVIDES:=gluon-mesh-provider
endef


$(eval $(call BuildPackageGluon,gluon-mesh-olsrd))
