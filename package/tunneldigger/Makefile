include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_REV:=HEAD

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=git://github.com/wlanslovenija/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

include $(INCLUDE_DIR)/package.mk

define Package/tunneldigger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnl-tiny
  TITLE:=L2TPv3 tunnel broker client
endef

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
	$(INSTALL_DIR) $(1)/lib/tunneldigger
	$(INSTALL_BIN) ./files/iface_setup.sh $(1)/lib/tunneldigger/iface_setup.sh
endef

$(eval $(call BuildPackage,tunneldigger))
