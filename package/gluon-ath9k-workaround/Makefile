include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ath9k-workaround
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ath9k-workaround
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=ATH9K Workaround
  DEPENDS:=+gluon-cron
endef

define Package/gluon-ath9k-workaround/description
	Gluon community wifi mesh firmware framework: ath9k wifi bug workaround
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ath9k-workaround/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ath9k-workaround))
