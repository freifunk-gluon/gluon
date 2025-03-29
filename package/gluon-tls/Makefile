include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-tls

include ../gluon.mk

define Package/gluon-tls
  DEPENDS:=+libustream-mbedtls +ca-bundle
  TITLE:=Enable TLS support
endef

define Package/gluon-tls/install
	$(INSTALL_DIR) $(1)/lib/gluon/features
	touch $(1)/lib/gluon/features/tls
endef

$(eval $(call BuildPackageGluon,gluon-tls))
