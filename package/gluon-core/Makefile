include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core

PKG_CONFIG_DEPENDS := CONFIG_GLUON_VERSION

include ../gluon.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gluon-core
  TITLE:=Base files of Gluon
  DEPENDS:= \
	+gluon-site +libgluonutil +libiwinfo-lua +lua-platform-info +lua-simple-uci +lua-hash +lua-jsonc \
	+luabitop +luaposix +vxlan +odhcp6c +firewall +pretty-hostname
endef

define Package/gluon-core/description
	Gluon community wifi mesh firmware framework: core
endef

define Package/gluon-core/config
config GLUON_VERSION
	string "Gluon version number"
	depends on PACKAGE_gluon-core
	default ""

config GLUON_MINIFY
	bool "Minify Gluon scripts"
	default y

config GLUON_BASE
	bool "Exclude everything except the very most basic"
	default n
endef

define Package/gluon-core/conffiles
/etc/config/gluon
endef

define Package/gluon-core/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon
	echo '$(call qstrip,$(CONFIG_GLUON_VERSION))' > $(1)/lib/gluon/gluon-version

ifdef CONFIG_GLUON_BASE
	find $(1)/lib/gluon/upgrade/ -type f -and ! -name "998-commit" -and ! -name "005-set-domain" -and ! -name "010-primary-mac" -and ! -name "030-system" -and ! -name "120-ntp-servers"　-and ! -name "150-poe-passthrough" -and ! -name "300-firewall-rules" -and ! -name "820-dns-config" -and ! -name "999-version" -delete
endif
endef

$(eval $(call BuildPackageGluon,gluon-core))
