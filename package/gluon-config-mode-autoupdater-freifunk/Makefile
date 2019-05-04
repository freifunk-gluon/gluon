include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-autoupdater-freifunk
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-config-mode-autoupdater-freifunk
  TITLE:=Config Mode: Ask the user for consent regarding automatic updates based on Freifunk's Memorandum of Understanding. This includes a view for the wizzard and for the admin section
  DEPENDS:=+gluon-config-mode-core +gluon-autoupdater
  CONFLICTS:=gluon-config-mode-autoupdater gluon-web-autoupdater
endef

$(eval $(call BuildPackageGluon,gluon-config-mode-autoupdater-freifunk))
