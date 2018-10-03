include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-debug
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include ../gluon.mk

define Package/gluon-debug
  TITLE:=Provides process runtime information to the network
  DEPENDS:=+libgluonutil +respondd
endef

define Package/gluon-debug/install
	$(Gluon/Build/Install)
endef

$(eval $(call BuildPackage,gluon-debug))
