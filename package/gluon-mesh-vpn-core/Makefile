include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-vpn-core
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-mesh-vpn-core
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Basic support for connecting meshes via VPN tunnels
  DEPENDS:=+gluon-core +gluon-wan-dnsmasq +iptables +iptables-mod-extra +simple-tc
  USERID:=:gluon-mesh-vpn=800
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-mesh-vpn-core/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
endef

define Package/gluon-mesh-vpn-core/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-mesh-vpn-core))
