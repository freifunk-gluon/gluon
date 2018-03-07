include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-lock-password
PKG_VERSION:=1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/gluon-lock-password
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Locks the root account by default
  DEPENDS:=+gluon-core
endef

define Package/gluon-lock-password/description
	This packages locks the root account by default.
endef

define Build/Compile
endef

define Package/gluon-lock-password/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-lock-password))
