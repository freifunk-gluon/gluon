include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-mesh-batman-adv-brmldproxy

include $(TOPDIR)/../package/gluon.mk

define Package/$(PKG_NAME)
  TITLE:=Bridge MLD Proxy for Gluon
  DEPENDS:=+tc +kmod-sched +brmldproxy +ip-bridge gluon-mesh-batman-adv
endef

define Package/$(PKG_NAME)/description
	Gluon community wifi mesh firmware framework: Configuration to
	enable brmldproxy in Gluon with batman-adv.

	If filter_membership_reports is false in the site.conf
	then no multicast listener is filtered, but the node will
	respond on behalf of any of its local listeners, potentially
	reducing duplicate MLD report overhead.

	If filter_membership_reports is true in the site.conf
	or absent then brmldproxy is additionally configured to
	only send MLD reports for routeable IPv6 multicast addresses
	and only to detected IPv6 multicast routers. If no such
	router is detected or no local listeners for routeable
	IPv6 multicast addresses exists then no MLD report is send
	into the mesh. Which greatly reduces MLD overhead while
	still allowing the usage of layer 3 IPv6 multicast routers.
	This is the recommended setting especially in larger meshes.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/brmldproxy
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
