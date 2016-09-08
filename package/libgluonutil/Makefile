include $(TOPDIR)/rules.mk

PKG_NAME:=libgluonutil
PKG_VERSION:=1
CMAKE_INSTALL:=1

PKG_LICENSE:=BSD-2-Clause

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk
include $(INCLUDE_DIR)/cmake.mk


define Package/libgluonutil
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Gluon utility library
  DEPENDS:=+libjson-c
endef

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE:String="MINSIZEREL"


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/libgluonutil/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libgluonutil.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgluonutil))
