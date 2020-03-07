all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

# check for spaces & resolve possibly relative paths
define mkabspath
   ifneq (1,$(words [$($(1))]))
     $$(error $(1) must not contain spaces)
   endif
   override $(1) := $(abspath $($(1)))
endef

GLUON_SITEDIR ?= site
$(eval $(call mkabspath,GLUON_SITEDIR))

$(GLUON_SITEDIR)/site.mk:
	$(error No site configuration was found. Please check out a site configuration to $(GLUON_SITEDIR))

include $(GLUON_SITEDIR)/site.mk

GLUON_RELEASE ?= $(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line)

GLUON_DEPRECATED ?= $(error GLUON_DEPRECATED not set. Please consult the documentation)

# initialize (possibly already user set) directory variables
GLUON_TMPDIR ?= tmp
GLUON_OUTPUTDIR ?= output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_PACKAGEDIR ?= $(GLUON_OUTPUTDIR)/packages
GLUON_TARGETSDIR ?= targets
GLUON_PATCHESDIR ?= patches

$(eval $(call mkabspath,GLUON_TMPDIR))
$(eval $(call mkabspath,GLUON_OUTPUTDIR))
$(eval $(call mkabspath,GLUON_IMAGEDIR))
$(eval $(call mkabspath,GLUON_PACKAGEDIR))
$(eval $(call mkabspath,GLUON_TARGETSDIR))
$(eval $(call mkabspath,GLUON_PATCHESDIR))

GLUON_MULTIDOMAIN ?= 0
GLUON_DEBUG ?= 0

export GLUON_RELEASE GLUON_REGION GLUON_MULTIDOMAIN GLUON_DEBUG GLUON_DEPRECATED GLUON_DEVICES \
	 GLUON_TARGETSDIR GLUON_PATCHESDIR GLUON_TMPDIR GLUON_IMAGEDIR GLUON_PACKAGEDIR

show-release:
	@echo '$(GLUON_RELEASE)'


update: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/patch.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/feeds.sh

update-patches: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update-patches.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/patch.sh

update-feeds: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/feeds.sh


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

GLUON_CONFIG_VARS := \
	GLUON_SITEDIR='$(GLUON_SITEDIR)' \
	GLUON_RELEASE='$(GLUON_RELEASE)' \
	GLUON_BRANCH='$(GLUON_BRANCH)' \
	GLUON_LANGS='$(GLUON_LANGS)' \
	BOARD='$(BOARD)' \
	SUBTARGET='$(SUBTARGET)'


CheckTarget := [ '$(BOARD)' ] \
	|| (echo 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:'; $(foreach target,$(GLUON_TARGETS),echo ' * $(target)';) false)

CheckExternal := test -d openwrt || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)

define CheckSite
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' GLUON_SITE_CONFIG='$(1).conf' $(LUA) -e 'assert(dofile("scripts/site_config.lua")(os.getenv("GLUON_SITE_CONFIG")))' \
		|| (echo 'Your site configuration ($(1).conf) did not pass validation.'; false)

endef

list-targets: FORCE
	@$(foreach target,$(GLUON_TARGETS),echo '$(target)';)

lint: lint-lua lint-sh

lint-lua: FORCE
	@scripts/lint-lua.sh

lint-sh: FORCE
	@scripts/lint-sh.sh

define merge_lists
  $(1) :=
  $(foreach pkg,$(2),
    $(1) := $$(strip $$(filter-out -$$(patsubst -%,%,$(pkg)) $$(patsubst -%,%,$(pkg)),$$(value $(1))) $(pkg))
  )
endef

define feature_packages
  $(1) := $(shell scripts/features.sh '$(2)' || echo '__ERROR__')
endef

$(eval $(call merge_lists,GLUON_FEATURE_LIST_standard,$(GLUON_FEATURES) $(GLUON_FEATURES_standard)))
$(eval $(call merge_lists,GLUON_FEATURE_LIST_tiny,$(GLUON_FEATURES) $(GLUON_FEATURES_tiny)))

$(eval $(call feature_packages,GLUON_FEATURE_PACKAGES_standard,$(GLUON_FEATURE_LIST_standard)))
$(eval $(call feature_packages,GLUON_FEATURE_PACKAGES_tiny,$(GLUON_FEATURE_LIST_tiny)))

ifneq ($(filter __ERROR__,$(GLUON_FEATURES_standard) $(GLUON_FEATURES_tiny)),)
  $(error Error while evaluating features)
endif

$(eval $(call merge_lists,GLUON_DEFAULT_PACKAGES,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES)))
$(eval $(call merge_lists,GLUON_CLASS_PACKAGES_standard,$(GLUON_FEATURE_PACKAGES_standard) $(GLUON_SITE_PACKAGES_standard)))
$(eval $(call merge_lists,GLUON_CLASS_PACKAGES_tiny,$(GLUON_FEATURE_PACKAGES_tiny) $(GLUON_SITE_PACKAGES_tiny)))


LUA := openwrt/staging_dir/hostpkg/bin/lua

$(LUA):
	@$(CheckExternal)

	+@[ -e openwrt/.config ] || $(OPENWRTMAKE) defconfig
	+@$(OPENWRTMAKE) tools/install
	+@$(OPENWRTMAKE) package/lua/host/compile


config: $(LUA) FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	$(foreach conf,site $(patsubst $(GLUON_SITEDIR)/%.conf,%,$(wildcard $(GLUON_SITEDIR)/domains/*.conf)),$(call CheckSite,$(conf)))

	@$(GLUON_CONFIG_VARS) \
		$(LUA) scripts/target_config.lua '$(GLUON_TARGET)' '$(GLUON_DEFAULT_PACKAGES)' '$(GLUON_CLASS_PACKAGES_standard)' '$(GLUON_CLASS_PACKAGES_tiny)' \
		> openwrt/.config
	+@$(OPENWRTMAKE) defconfig

	@$(GLUON_CONFIG_VARS) \
		$(LUA) scripts/target_config_check.lua '$(GLUON_TARGET)' '$(GLUON_DEFAULT_PACKAGES)' '$(GLUON_CLASS_PACKAGES_standard)' '$(GLUON_CLASS_PACKAGES_tiny)'


all: config
	@$(GLUON_CONFIG_VARS) \
		$(LUA) scripts/clean_output.lua
	+@$(OPENWRTMAKE)
	@$(GLUON_CONFIG_VARS) \
		$(LUA) scripts/copy_output.lua '$(GLUON_TARGET)'

clean download: config
	+@$(OPENWRTMAKE) $@

dirclean: FORCE
	+@[ -e openwrt/.config ] || $(OPENWRTMAKE) defconfig
	+@$(OPENWRTMAKE) dirclean
	@rm -rf $(GLUON_TMPDIR) $(GLUON_OUTPUTDIR)

manifest: $(LUA) FORCE
	@[ '$(GLUON_BRANCH)' ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
	@echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
	@$(CheckExternal)

	@( \
		echo 'BRANCH=$(GLUON_BRANCH)' && \
		echo "DATE=$$($(LUA) scripts/rfc3339date.lua)" && \
		echo 'PRIORITY=$(GLUON_PRIORITY)' && \
		echo && \
		$(foreach GLUON_TARGET,$(GLUON_TARGETS), \
			GLUON_SITEDIR='$(GLUON_SITEDIR)' $(LUA) scripts/generate_manifest.lua '$(GLUON_TARGET)' && \
		) : \
	) > 'tmp/$(GLUON_BRANCH).manifest.tmp'

	@mkdir -p '$(GLUON_IMAGEDIR)/sysupgrade'
	@mv 'tmp/$(GLUON_BRANCH).manifest.tmp' '$(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest'

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:
