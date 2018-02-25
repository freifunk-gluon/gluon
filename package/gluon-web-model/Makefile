include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-web-model
PKG_VERSION:=1


include ../gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-web-model
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Minimal Lua web framework derived from LuCI (model support)
  DEPENDS:=+gluon-web
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-web-model,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-web-model/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-web-model,$(1))

endef

$(eval $(call BuildPackage,gluon-web-model))
