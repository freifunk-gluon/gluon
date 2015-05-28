# Makefile for OpenWrt
#
# Copyright (C) 2007-2012 OpenWrt.org
# Copyright (C) 2013-2014 Project Gluon
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

RELEASE:=Barrier Breaker
PREP_MK= OPENWRT_BUILD= QUIET=0

export IS_TTY=$(shell tty -s && echo 1 || echo 0)

include $(GLUONDIR)/include/verbose.mk

REVISION:=$(shell [ -d $(TOPDIR) ] && cd $(TOPDIR) && ./scripts/getver.sh 2>/dev/null)

HOSTCC ?= gcc
OPENWRTVERSION:=$(RELEASE)$(if $(REVISION), ($(REVISION)))
export RELEASE
export REVISION
export OPENWRTVERSION
export IS_TTY=$(shell tty -s && echo 1 || echo 0)
export LD_LIBRARY_PATH:=$(subst ::,:,$(if $(LD_LIBRARY_PATH),$(LD_LIBRARY_PATH):)$(STAGING_DIR_HOST)/lib)
export DYLD_LIBRARY_PATH:=$(subst ::,:,$(if $(DYLD_LIBRARY_PATH),$(DYLD_LIBRARY_PATH):)$(STAGING_DIR_HOST)/lib)
export GIT_CONFIG_PARAMETERS='core.autocrlf=false'
export MAKE_JOBSERVER=$(filter --jobserver%,$(MAKEFLAGS))

# prevent perforce from messing with the patch utility
unexport P4PORT P4USER P4CONFIG P4CLIENT

# prevent user defaults for quilt from interfering
unexport QUILT_PATCHES QUILT_PATCH_OPTS

unexport C_INCLUDE_PATH CROSS_COMPILE ARCH

# prevent distro default LPATH from interfering
unexport LPATH

# make sure that a predefined CFLAGS variable does not disturb packages
export CFLAGS=

ifneq ($(shell $(HOSTCC) 2>&1 | grep clang),)
  export HOSTCC_REAL?=$(HOSTCC)
  export HOSTCC_WRAPPER:=$(TOPDIR)/scripts/clang-gcc-wrapper
else
  export HOSTCC_WRAPPER:=$(HOSTCC)
endif

SCAN_COOKIE?=$(shell echo $$$$)
export SCAN_COOKIE

SUBMAKE:=umask 022; $(SUBMAKE)

ULIMIT_FIX=_limit=`ulimit -n`; [ "$$_limit" = "unlimited" -o "$$_limit" -ge 1024 ] || ulimit -n 1024;

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:

