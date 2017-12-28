# SPDX-License-Identifier: MIT
#
# batman-adv helpers functions library
#
# Copyright (c) 2017, Sven Eckelmann <sven@narfation.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include $(TOPDIR)/rules.mk

PKG_NAME:=libbatadv
PKG_VERSION:=1
PKG_LICENSE:=MIT

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libbatadv
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=batman-adv helpers functions
  DEPENDS:=+libnl-tiny
endef


TARGET_CFLAGS  += -flto -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -fuse-linker-plugin -Wl,--gc-sections

MAKE_VARS += \
        LIBNL_NAME="libnl-tiny" \
        LIBNL_GENL_NAME="libnl-tiny"

MAKE_ARGS += \
	PREFIX=/usr

MAKE_INSTALL_FLAGS += \
	PREFIX=/usr

define Package/libbatadv/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbatadv.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) ./files/libbatadv.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libbatadv))
