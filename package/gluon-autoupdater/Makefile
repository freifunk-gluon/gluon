include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-autoupdater
PKG_VERSION:=4

PKG_CONFIG_DEPENDS := CONFIG_GLUON_BRANCH

include ../gluon.mk

define Package/gluon-autoupdater
  DEPENDS:=+gluon-core +libgluonutil +micrond +autoupdater
  TITLE:=Automatically update firmware
endef

define Package/gluon-autoupdater/config
config GLUON_BRANCH
	string "Gluon autoupdater branch"
	depends on PACKAGE_gluon-autoupdater
	default ""
endef

define Package/gluon-autoupdater/install
	$(Gluon/Build/Install)

ifneq ($(CONFIG_GLUON_BRANCH),"")
	$(INSTALL_DIR) $(1)/lib/gluon/autoupdater
	echo '$(call qstrip,$(CONFIG_GLUON_BRANCH))' > $(1)/lib/gluon/autoupdater/default_branch
endif
endef

$(eval $(call BuildPackageGluon,gluon-autoupdater))
