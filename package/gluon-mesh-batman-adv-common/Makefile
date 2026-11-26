include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv-common

include ../gluon.mk

define Package/gluon-mesh-batman-adv-common
  TITLE:=Common files for batman-adv meshing
  DEPENDS:= \
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

$(eval $(call BuildPackageGluon,gluon-mesh-batman-adv-common))
