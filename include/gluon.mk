ifneq ($(__gluon_inc),1)
__gluon_inc=1

GLUON_OPENWRTDIR := $(GLUONDIR)/openwrt
GLUON_SITEDIR := $(GLUONDIR)/site

GLUON_IMAGEDIR ?= $(GLUONDIR)/images
GLUON_BUILDDIR ?= $(GLUONDIR)/build

BOARD_BUILDDIR = $(GLUON_BUILDDIR)/$(BOARD)
BOARD_KDIR = $(BOARD_BUILDDIR)/kernel

export GLUONDIR GLUON_SITEDIR GLUON_IMAGEDIR GLUON_OPENWRTDIR GLUON_BUILDDIR


CONFIG_VERSION_REPO := http://downloads.openwrt.org/attitude_adjustment/12.09/%S/packages

export CONFIG_VERSION_REPO

$(GLUON_SITEDIR)/site.mk:
	$(error There was no site configuration found. Please check out a site configuration to $(GLUON_SITEDIR))

-include $(GLUON_SITEDIR)/site.mk


GLUON_VERSION := $(shell cd $(GLUONDIR) && git describe --always 2>/dev/null || echo unknown)
export GLUON_VERSION


ifeq ($(OPENWRT_BUILD),1)
ifeq ($(GLUON_TOOLS),1)

GLUON_CONFIG_VERSION := $(shell test -d $(GLUON_SITEDIR) && (cd $(GLUON_SITEDIR) && git describe --always --dirty=.$$($(STAGING_DIR_HOST)/bin/stat -c %Y $(GLUON_SITEDIR)/site.conf) 2>/dev/null || $(STAGING_DIR_HOST)/bin/stat -c %Y site.conf))
export GLUON_CONFIG_VERSION

GLUON_SITE_CODE := $(shell $(GLUONDIR)/scripts/site.sh site_code)
export GLUON_SITE_CODE

GLUON_RELEASE ?= $(shell $(GLUONDIR)/scripts/site.sh release)
export GLUON_RELEASE

endif
endif


define merge-lists
$(1) :=
$(foreach var,$(2),$(1) := $$(sort $$(filter-out -% $$(patsubst -%,%,$$(filter -%,$$($(var)))),$$($(1)) $$($(var))))
)
endef

regex-escape = $(shell echo '$(1)' | sed -e 's/[]\/()$*.^|[]/\\&/g')

GLUON_DEFAULT_PACKAGES := gluon-core kmod-ipv6 firewall ip6tables -uboot-envtools

override DEFAULT_PACKAGES.router :=

endif #__gluon_inc
