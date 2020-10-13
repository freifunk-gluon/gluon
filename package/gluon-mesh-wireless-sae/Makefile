include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-wireless-sae
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-wireless-sae
  TITLE:=Encryption of 802.11s Mesh Links through SAE
  DEPENDS:=+gluon-core +wpa-supplicant-mesh-wolfssl
endef

$(eval $(call BuildPackageGluon,gluon-mesh-wireless-sae))
