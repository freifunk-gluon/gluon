include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ssid-changer
PKG_VERSION:=5

include $(TOPDIR)/../package/gluon.mk

define Package/$(PKG_NAME)
  TITLE:=changes the SSID to an Offline-SSID so clients don't connect to an offline WiFi
  DEPENDS:=+gluon-core +micrond
endef

define Package/$(PKG_NAME)/description
  Script to change the SSID to an Offline-SSID when there is no connection to
  any gateway. This SSID can be generated from the node's hostname with the
  first and last part of the nodename or the mac address, to allow observers to 
  recognise which node is down. The script is called once a minute by micrond
  and it will change from online to Offline-SSID once per definable timeframe at
  most.
endef


define Build/Compile
	$(call Gluon/Build/Compile)
	./gluonShellDiet.sh shsrc/ssid-changer.sh > $(PKG_BUILD_DIR)/ssid-changer.sh
endef

define Package/$(PKG_NAME)/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/ssid-changer
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssid-changer.sh $(1)/lib/gluon/ssid-changer/
endef


$(eval $(call BuildPackageGluon,$(PKG_NAME)))
