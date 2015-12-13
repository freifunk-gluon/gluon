include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger
PKG_VERSION:=0.4.5
PKG_RELEASE:=1
PKG_REV:=f820d65e57098094231083c2e83ed4983d2be049

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=git://github.com/ffrl/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

include $(INCLUDE_DIR)/package.mk

define Package/tunneldigger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnl-tiny +kmod-l2tp +kmod-l2tp-ip +kmod-l2tp-eth +librt +libpthread
  TITLE:=L2TPv3 tunnel broker client
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(STAGING_DIR)/usr/include \
	-DLIBNL_TINY

define Build/Prepare
	$(call Build/Prepare/Default)
	mv $(PKG_BUILD_DIR)/client/* $(PKG_BUILD_DIR)
	sed -i s/-lnl/-lnl-tiny/g $(PKG_BUILD_DIR)/Makefile
endef

define Package/tunneldigger/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/l2tp_client $(1)/usr/bin/tunneldigger
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tunneldigger.init $(1)/etc/init.d/tunneldigger
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/config.default $(1)/etc/config/tunneldigger
endef

define Package/tunneldigger/conffiles
/etc/config/tunneldigger
endef

$(eval $(call BuildPackage,tunneldigger))
