include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-statistics-mcast
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-statistics-mcast
  TITLE:=Gluon Statistics for Multicast Traffic
  DEPENDS:= +bpfcountd +libgluonutil
endef

define Package/gluon-statistics-mcast/description
	This package collects disected statistics on multicast
	and management traffic and provides them via respondd in
	"statistics-extended". Such information can be helpful
	for further development and comparison of mesh routing
	protocols and troubleshooting network issues.

	The statistics gathered disect into batman-adv
	packets as well. Statistics are collected both on client
	bridge ports and br-client as well as mesh interfaces.

	This introduces a performance penalty but tries to
	keep the impact on unicast traffic small.

	Note that respondd replies are rather large
	(several UDP datagrams, even when LZMA compressed).
	Therefore you might want to use slower intervals for
	querying respondd "statistics-extended".
endef

$(eval $(call BuildPackageGluon,gluon-statistics-mcast))
