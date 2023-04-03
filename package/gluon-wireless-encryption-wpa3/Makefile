include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-wireless-encryption-wpa3

include ../gluon.mk

define Package/gluon-wireless-encryption-wpa3
  DEPENDS:=+hostapd-wolfssl
  TITLE:=Package for supporting WPA3 encrypted wireless networks
endef

define Package/gluon-wireless-encryption-wpa3/install
	$(INSTALL_DIR) $(1)/lib/gluon/features

	touch $(1)/lib/gluon/features/wpa2
	touch $(1)/lib/gluon/features/wpa3
endef

$(eval $(call BuildPackageGluon,gluon-wireless-encryption-wpa3))
