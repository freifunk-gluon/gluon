include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-wireless-sae

include ../gluon.mk

define Package/gluon-mesh-wireless-sae
  TITLE:=Encryption of 802.11s Mesh Links through SAE
  DEPENDS:=+gluon-core +wpa-supplicant-mesh-mbedtls
endef

$(eval $(call BuildPackageGluon,gluon-mesh-wireless-sae))
