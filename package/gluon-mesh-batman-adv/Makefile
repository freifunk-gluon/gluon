include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-batman-adv/common
  PROVIDES:=gluon-mesh-batman-adv
  DEPENDS:= \
	+gluon-core \
	+libgluonutil \
	+gluon-client-bridge \
	+gluon-ebtables \
	+firewall \
	+libiwinfo \
	+kmod-dummy \
	+libnl-tiny \
	+libbatadv \
	+batctl \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_DUMMY \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_CRC16 \
	+@GLUON_SPECIALIZE_KERNEL:KERNEL_LIBCRC32C
endef

define Package/gluon-mesh-batman-adv-14
$(Package/gluon-mesh-batman-adv/common)
  TITLE:=Support for batman-adv meshing (compat level 14)
  CONFLICTS:=gluon-mesh-batman-adv-15
  DEPENDS+=+kmod-batman-adv-legacy
endef

define Package/gluon-mesh-batman-adv-15
$(Package/gluon-mesh-batman-adv/common)
  TITLE:=Support for batman-adv meshing (compat level 15)
  DEPENDS+=+kmod-batman-adv
endef

define Package/gluon-mesh-batman-adv-14/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/mesh-batman-adv
	echo 14 > $(1)/lib/gluon/mesh-batman-adv/compat
endef

define Package/gluon-mesh-batman-adv-15/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/mesh-batman-adv
	echo 15 > $(1)/lib/gluon/mesh-batman-adv/compat
endef

$(eval $(call BuildPackageGluon,gluon-mesh-batman-adv-14))
$(eval $(call BuildPackageGluon,gluon-mesh-batman-adv-15))
