include $(TOPDIR)/rules.mk

PKG_NAME:=ffnw-hoods
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DEPENDS := luci-base/host lua-cjson/host

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/ffnw-hoods
  SECTION:=networke
  CATEGORY:=Freifunk Nordwest
  TITLE:=Hoodjson file
endef

define Package/ffnw-hoods/description
	Hoodjson file for defined hoods
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffnw-hoods/install
	$(INSTALL_DIR) $(1)/lib/ffnw/hoods
	lua -e 'local cjson = require("cjson"); print(cjson.encode(cjson.decode(assert(io.open("./files/lib/ffnw/hoods/hoods.json"):read("*a")))))' > $(1)/lib/ffnw/hoods/hoods.json
endef

$(eval $(call BuildPackage,ffnw-hoods))
