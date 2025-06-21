include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-state-ntpd-check

include ../gluon.mk

define Package/gluon-state-ntpd-check
  TITLE:=Hotplug for ntpd into gluon-state-check
  DEPENDS:=+gluon-core +gluon-state-check
endef

$(eval $(call BuildPackageGluon,gluon-state-ntpd-check))
