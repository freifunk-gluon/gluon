include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-manman-sync
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-manman-sync
	# luci-base shouldn't be here but httpclient depends on util depends on template.parser which is from base
  DEPENDS:=+gluon-core +micrond +luci-lib-ip +luci-lib-httpclient +luci-base +gluon-lib-ecdsa
  TITLE:=Sync configuration with data from manman
endef

$(eval $(call BuildPackageGluon,gluon-manman-sync))
