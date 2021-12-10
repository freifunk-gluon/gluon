include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-wan-dnsmasq

include ../gluon.mk

define Package/gluon-wan-dnsmasq
  TITLE:=Support for a secondary DNS server using the WAN interface
  DEPENDS:=+gluon-core +libubus-lua +dnsmasq +libpacketmark
endef

define Package/gluon-wan-dnsmasq/description
	Gluon community wifi mesh firmware framework: Support for a secondary DNS server using the WAN interface
endef

define Package/gluon-wan-dnsmasq/conffiles
/etc/config/gluon-wan-dnsmasq
endef

$(eval $(call BuildPackageGluon,gluon-wan-dnsmasq))
