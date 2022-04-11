include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-manman-sync
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-manman-sync
  DEPENDS:=+gluon-core +micrond +luci-lib-ip +luci-lib-httpclient +gluon-lib-ecdsa
  TITLE:=Sync configuration with data from manman
endef

define Package/gluon-manman-sync/install
	$(Gluon/Build/Install)

	# httpclient depends on util depends on template.parser & sys.zoneinfo which is from +luci-base
	# +luci-base is quite big and unnesesarry. stubbing the files is enough to make it work.
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/template
	touch $(1)/usr/lib/lua/luci/template/parser.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/sys
	touch $(1)/usr/lib/lua/luci/sys/zoneinfo.lua
endef

$(eval $(call BuildPackageGluon,gluon-manman-sync))
