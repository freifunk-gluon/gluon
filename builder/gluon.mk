ifneq ($(__gluon_inc),1)
__gluon_inc=1

GLUON_SITEDIR:=$(GLUONDIR)/site
GLUON_IMAGEDIR:=$(GLUONDIR)/images
GLUON_OPENWRTDIR:=$(GLUONDIR)/openwrt
GLUON_BUILDERDIR:=$(GLUONDIR)/builder
GLUON_BUILDDIR:=$(GLUONDIR)/build

$(GLUON_SITEDIR)/site.mk:
	$(error There was no site configuration found. Please check out a site configuration to $(GLUON_SITEDIR))

-include $(GLUON_SITEDIR)/site.mk

GLUON_DEFAULT_PACKAGES:=gluon-core


GLUON_PACKAGES:=$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES)
DEFAULT_PACKAGES.gluon:=$(GLUON_PACKAGES)
DEVICE_TYPE:=gluon

endif #__gluon_inc
