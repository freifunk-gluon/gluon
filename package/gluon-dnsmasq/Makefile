include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-dnsmasq

include ../gluon.mk

define Package/gluon-dnsmasq
  TITLE:=dnsmasq meta-package
  DEPENDS:= \
	+gluon-core \
	+GLUON_DNSMASQ_VARIANT_TINY:dnsmasq \
	+GLUON_DNSMASQ_VARIANT_DEFAULT:dnsmasq-full
endef

define Package/gluon-dnsmasq/description
	Gluon dnsmasq package selection
endef

define Package/gluon-dnsmasq/config
	choice
		prompt "Dnsmasq variant"
		default GLUON_DNSMASQ_VARIANT_DEFAULT

	config GLUON_DNSMASQ_VARIANT_TINY
		bool "Tiny"

	config GLUON_DNSMASQ_VARIANT_DEFAULT
		bool "Default"
	endchoice
endef

define Package/gluon-dnsmasq/install
	$(Gluon/Build/Install)

	$(INSTALL_DIR) $(1)/lib/gluon
  ifneq ($(CONFIG_GLUON_DNSMASQ_VARIANT_TINY),y)
	echo 'tiny' > $(1)/lib/gluon/gluon-dnsmasq-variant
  else
	echo 'default' > $(1)/lib/gluon/gluon-dnsmasq-variant
  endif
endef

$(eval $(call BuildPackageGluon,gluon-dnsmasq))

