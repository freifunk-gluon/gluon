include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-batman-adv-15
  PROVIDES:=gluon-mesh-batman-adv
  TITLE:=Support for batman-adv meshing (compat level 15)
  DEPENDS+= \
	+kmod-batman-adv \
	+gluon-core \
	+libgluonutil \
	+gluon-client-bridge \
	+gluon-ebtables \
	+firewall \
	+libiwinfo \
	+kmod-dummy \
	+libnl-tiny \
	+libbatadv \
	+batctl
endef

$(eval $(call BuildPackageGluon,gluon-mesh-batman-adv-15))
