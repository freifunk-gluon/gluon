include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-babel

PKG_BUILD_DEPENDS := libbabelhelper
PKG_BUILD_DEPENDS += libjson-c

include ../gluon.mk

define Package/gluon-mesh-babel
  TITLE:=Babel mesh
  DEPENDS:=+gluon-core +babeld +gluon-mesh-layer3-common +libiwinfo +libgluonutil +firewall4 +libjson-c +libnl-tiny +libubus +libubox +libblobmsg-json +libbabelhelper +luabitop
  PROVIDES:=gluon-mesh-provider
endef

define Package/gluon-mesh-babel/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/status-page/providers
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neighbours-babel $(1)/lib/gluon/status-page/providers/
endef

$(eval $(call BuildPackageGluon,gluon-mesh-babel))
