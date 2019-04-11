include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-respondd
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-respondd
  TITLE:=Provides node information to the network
  DEPENDS:=+gluon-core +libplatforminfo +libgluonutil +libuci +ubus +respondd +respondd-wifi
endef

$(eval $(call BuildPackageGluon,gluon-respondd))
