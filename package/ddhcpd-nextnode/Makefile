include $(TOPDIR)/rules.mk

PKG_NAME:=ddhcpd-nextnode
PKG_RELEASE:=1

include ../gluon.mk

define Package/ddhcpd-nextnode
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+ddhcpd
	TITLE:=ddhcpd nextnode integration
endef

define Package/ddhcpd-nextnode/description
  nextnode integration for ddhcpd
endef

$(eval $(call BuildPackage,ddhcpd-nextnode))
