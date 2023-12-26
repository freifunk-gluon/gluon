include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-tls

include ../gluon.mk

define Package/gluon-tls
  DEPENDS:=+libustream-mbedtls +ca-bundle
  TITLE:=Dummy Package to select the current TLS implementation
endef

$(eval $(call BuildPackageGluon,gluon-tls))
