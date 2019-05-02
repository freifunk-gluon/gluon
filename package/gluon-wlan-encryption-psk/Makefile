include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-wlan-encryption-psk
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-wlan-encryption-psk
  TITLE:=Encrypt wlan using a pre-shared key (psk)
  DEPENDS:=+gluon-core +wpad-mesh-wolfssl
endef

$(eval $(call BuildPackageGluon,gluon-wlan-encryption-psk))
