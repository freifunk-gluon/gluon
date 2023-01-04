include $(TOPDIR)/rules.mk

PKG_NAME:=libgluonutil
PKG_VERSION:=1
CMAKE_INSTALL:=1

PKG_LICENSE:=BSD-2-Clause

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libgluonutil
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Gluon utility library
	DEPENDS:=+libjson-c +libuci
endef

define Package/libgluonutil/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libgluonutil.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgluonutil))
