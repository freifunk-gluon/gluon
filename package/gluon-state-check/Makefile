include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-state-check

include ../gluon.mk

define Package/gluon-state-check
	TITLE:=Provides info about the routers state
	DEPENDS:=+gluon-core +micrond
endef

define Package/gluon-state-check/description
	gluon-state-check executes checks in `/lib/gluon/state/check.d/` and provides
	a flag file for each check in `/var/gluon/state` depending on the return code
	of the check. A flag file is created (or "touched") if the corresponding check
	exits cleanly and gets removed otherwise. If the flags are "touched", they
	are only accessed, but not modified. In this way, the atime of a flag file
	reflects when the last check was performed and the mtime reflects when
	when the state was last changed.

	This package provides the following checks:
	- `has_default_gw6` - check whether the router has a default IPv6-route on br-client.

	The checks are executed once every minute (by micron.d).
endef

$(eval $(call BuildPackageGluon,gluon-state-check))
