include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater

PKG_CONFIG_DEPENDS := CONFIG_GLUON_AUTOUPDATER_BRANCH CONFIG_GLUON_AUTOUPDATER_ENABLED

include ../gluon.mk

define Package/gluon-autoupdater
	DEPENDS:=+gluon-core +libgluonutil +micrond +autoupdater
	TITLE:=Automatically update firmware
endef

define Package/gluon-autoupdater/config
	source "$(SOURCE)/Config.in"
endef

define Package/gluon-autoupdater/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon/autoupdater
	ifneq ($(CONFIG_GLUON_AUTOUPDATER_BRANCH),"")
	echo '$(call qstrip,$(CONFIG_GLUON_AUTOUPDATER_BRANCH))' > $(1)/lib/gluon/autoupdater/default_branch
	endif
	ifneq ($(CONFIG_GLUON_AUTOUPDATER_ENABLED),)
	touch $(1)/lib/gluon/autoupdater/default_enabled
	endif
endef

$(eval $(call BuildPackageGluon,gluon-autoupdater))
