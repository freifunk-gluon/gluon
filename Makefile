all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

.SHELLFLAGS = -ec

# check for spaces & resolve possibly relative paths
define mkabspath
   ifneq (1,$(words [$($(1))]))
     $$(error $(1) must not contain spaces)
   endif
   override $(1) := $(abspath $($(1)))
endef

escape = '$(subst ','\'',$(1))'

GLUON_SITEDIR ?= site
$(eval $(call mkabspath,GLUON_SITEDIR))

ifeq ($(realpath $(GLUON_SITEDIR)/site.mk),)
$(error No site configuration was found. Please check out a site configuration to $(GLUON_SITEDIR))
endif

include $(GLUON_SITEDIR)/site.mk

GLUON_RELEASE ?= $(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line)

GLUON_DEPRECATED ?= 0

ifneq ($(GLUON_BRANCH),)
  $(warning *** Warning: GLUON_BRANCH has been deprecated, please set GLUON_AUTOUPDATER_BRANCH and GLUON_AUTOUPDATER_ENABLED instead.)
  GLUON_AUTOUPDATER_BRANCH ?= $(GLUON_BRANCH)
  GLUON_AUTOUPDATER_ENABLED ?= 1
endif

GLUON_AUTOUPDATER_ENABLED ?= 0

# initialize (possibly already user set) directory variables
GLUON_TMPDIR ?= tmp
GLUON_OUTPUTDIR ?= output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_PACKAGEDIR ?= $(GLUON_OUTPUTDIR)/packages
GLUON_DEBUGDIR ?= $(GLUON_OUTPUTDIR)/debug
GLUON_TARGETSDIR ?= targets
GLUON_PATCHESDIR ?= patches
GLUON_PREFIX ?= openwrt

$(eval $(call mkabspath,GLUON_TMPDIR))
$(eval $(call mkabspath,GLUON_OUTPUTDIR))
$(eval $(call mkabspath,GLUON_IMAGEDIR))
$(eval $(call mkabspath,GLUON_PACKAGEDIR))
$(eval $(call mkabspath,GLUON_TARGETSDIR))
$(eval $(call mkabspath,GLUON_PATCHESDIR))

GLUON_VERSION := $(shell scripts/getversion.sh '.')
GLUON_SITE_VERSION := $(shell scripts/getversion.sh '$(GLUON_SITEDIR)')

GLUON_MULTIDOMAIN ?= 0
GLUON_AUTOREMOVE ?= 0
GLUON_DEBUG ?= 0
GLUON_MINIFY ?= 1
GLUON_BUILDTYPE ?= gluon

# Can be overridden via environment/command line/... to use the Gluon
# build system for non-Gluon builds
define GLUON_BASE_FEEDS ?=
src-link gluon_base ../../package
endef

GLUON_VARS = \
	GLUON_VERSION GLUON_SITE_VERSION \
	GLUON_RELEASE GLUON_REGION GLUON_MULTIDOMAIN GLUON_AUTOREMOVE GLUON_DEBUG GLUON_MINIFY GLUON_DEPRECATED \
	GLUON_DEVICES GLUON_TARGETSDIR GLUON_PATCHESDIR GLUON_TMPDIR GLUON_IMAGEDIR GLUON_PACKAGEDIR GLUON_DEBUGDIR \
	GLUON_SITEDIR GLUON_BUILDTYPE GLUON_AUTOUPDATER_BRANCH GLUON_AUTOUPDATER_ENABLED GLUON_LANGS GLUON_BASE_FEEDS GLUON_PREFIX \
	GLUON_TARGET BOARD SUBTARGET

unexport $(GLUON_VARS)
GLUON_ENV = $(foreach var,$(GLUON_VARS),$(var)=$(call escape,$($(var))))

show-release:
	@echo '$(GLUON_RELEASE)'


update: FORCE
	@
	export $(GLUON_ENV)
	scripts/update.sh
	scripts/patch.sh
	scripts/feeds.sh

update-patches: FORCE
	@
	export $(GLUON_ENV)
	scripts/update.sh
	scripts/update-patches.sh
	scripts/patch.sh

refresh-patches: FORCE
	@
	export $(GLUON_ENV)
	scripts/update.sh
	scripts/patch.sh
	scripts/update-patches.sh

update-feeds: FORCE
	@$(GLUON_ENV) scripts/feeds.sh

update-modules: FORCE
	@scripts/update-modules.sh

update-ci: FORCE
	@$(GLUON_ENV) scripts/update-ci.sh

GLUON_TARGETS :=

define GluonTarget
gluon_target := $(1)$$(if $(2),-$(2))
GLUON_TARGETS += $$(gluon_target)
GLUON_TARGET_$$(gluon_target)_BOARD := $(1)
GLUON_TARGET_$$(gluon_target)_SUBTARGET := $(2)
endef

include $(GLUON_TARGETSDIR)/targets.mk


OPENWRTMAKE = $(MAKE) -C openwrt

BOARD := $(GLUON_TARGET_$(GLUON_TARGET)_BOARD)
SUBTARGET := $(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)


define CheckTarget
	if [ -z '$(BOARD)' ]; then
		echo 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:'
		for target in $(GLUON_TARGETS); do
			echo " * $$target"
		done
		exit 1
	fi
endef

define CheckSite
	if ! GLUON_SITEDIR='$(GLUON_SITEDIR)' GLUON_SITE_CONFIG='$(1).conf' $(LUA) -e 'assert(dofile("scripts/site_config.lua")(os.getenv("GLUON_SITE_CONFIG")))'; then
		echo 'Your site configuration ($(1).conf) did not pass validation'
		exit 1
	fi
endef

list-targets: FORCE
	@for target in $(GLUON_TARGETS); do
		echo "$$target"
	done

lint: lint-editorconfig lint-lua lint-sh

lint-editorconfig: FORCE
	@scripts/lint-editorconfig.sh

lint-lua: FORCE
	@scripts/lint-lua.sh

lint-sh: FORCE
	@scripts/lint-sh.sh


LUA := openwrt/staging_dir/hostpkg/bin/lua

$(LUA):
	+@

	scripts/module_check.sh

	[ -e openwrt/.config ] || $(OPENWRTMAKE) defconfig
	$(OPENWRTMAKE) tools/install
	$(OPENWRTMAKE) package/lua/host/compile


config: $(LUA) FORCE
	+@

	scripts/module_check.sh
	$(CheckTarget)
	$(foreach conf,site $(patsubst $(GLUON_SITEDIR)/%.conf,%,$(wildcard $(GLUON_SITEDIR)/domains/*.conf)),\
		$(call CheckSite,$(conf)); \
	)

	$(OPENWRTMAKE) prepare-tmpinfo
	$(GLUON_ENV) $(LUA) scripts/target_config.lua > openwrt/.config
	$(OPENWRTMAKE) defconfig
	$(GLUON_ENV) $(LUA) scripts/target_config_check.lua


container: FORCE
	@scripts/container.sh


all: config
	+@
	$(GLUON_ENV) $(LUA) scripts/clean_output.lua
	$(OPENWRTMAKE)
	$(GLUON_ENV) $(LUA) scripts/copy_output.lua

clean download: config
	+@$(OPENWRTMAKE) $@

dirclean: FORCE
	+@
	[ -e openwrt/.config ] || $(OPENWRTMAKE) defconfig
	$(OPENWRTMAKE) dirclean
	rm -rf $(GLUON_TMPDIR) $(GLUON_OUTPUTDIR)

manifest: $(LUA) FORCE
	@
	[ '$(GLUON_AUTOUPDATER_BRANCH)' ] || (echo 'Please set GLUON_AUTOUPDATER_BRANCH to create a manifest.'; false)
	echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
	scripts/module_check.sh

	(
		export $(GLUON_ENV)
		echo 'BRANCH=$(GLUON_AUTOUPDATER_BRANCH)'
		echo "DATE=$$($(LUA) scripts/rfc3339date.lua)"
		echo 'PRIORITY=$(GLUON_PRIORITY)'
		echo
		for target in $(GLUON_TARGETS); do
			$(LUA) scripts/generate_manifest.lua "$$target"
		done
	) > 'tmp/$(GLUON_AUTOUPDATER_BRANCH).manifest.tmp'

	mkdir -p '$(GLUON_IMAGEDIR)/sysupgrade'
	mv 'tmp/$(GLUON_AUTOUPDATER_BRANCH).manifest.tmp' '$(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_AUTOUPDATER_BRANCH).manifest'

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:
.ONESHELL:
