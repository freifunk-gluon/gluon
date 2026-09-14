include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ucode

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=BSD-2-Clause
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gluon-ucode
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+libplatforminfo +libgluonutil +ucode +ubox
  TITLE:=Gluon ucode library
endef

define Package/gluon-ucode/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode/gluon/native $(1)/usr/share/ucode/gluon

	$(CP) $(PKG_BUILD_DIR)/util.so $(1)/usr/lib/ucode/gluon/native/util.so
	$(CP) $(PKG_BUILD_DIR)/platform.so $(1)/usr/lib/ucode/gluon/native/platform.so
	$(CP) $(PKG_BUILD_DIR)/system.so $(1)/usr/lib/ucode/gluon/native/system.so

	$(CP) ./files/pretty-hostname.uc $(1)/usr/share/ucode/gluon/pretty-hostname.uc
endef

$(eval $(call BuildPackage,gluon-ucode))
