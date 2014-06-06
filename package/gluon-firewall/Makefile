include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-firewall
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-firewall
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Restrictive firewall rules
  DEPENDS:=+gluon-core +firewall
endef

define Package/gluon-firewall/description
	Gluon community wifi mesh firmware framework:
	Firewall rules which try to ensure a node can't be abused
	(e.g. for DNS amplification attacks)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-firewall/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-firewall))
