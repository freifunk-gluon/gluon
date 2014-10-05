##	gluon site.mk makefile example

##	GLUON_SITE_PACKAGES
#		specify gluon/openwrt packages to include here
GLUON_SITE_PACKAGES := \
  gluon-alfred \
  gluon-announced \
  gluon-ath9k-workaround \
  gluon-autoupdater \
  gluon-config-mode \
  gluon-ebtables-filter-multicast \
  gluon-ebtables-filter-ra-dhcp \
  gluon-luci-admin \
  gluon-luci-autoupdater \
  gluon-luci-portconfig \
  gluon-next-node \
  gluon-mesh-batman-adv \
  gluon-mesh-vpn-fastd \
  gluon-radvd \
  gluon-status-page \
  iwinfo \
  iptables \
  haveged


##	DEFAULT_GLUON_RELEASE
#		version string to use for images
#		gluon relies on
#			opkg compare-versions "$1" '>>' "$2"
#		to decide if a version is newer or not.
DEFAULT_GLUON_RELEASE := 0.3+0-exp$(shell date '+%Y%m%d')


##	GLUON_RELEASE
#		call make with custom GLUON_RELEASE flag, to use your own release version scheme.
#		e.g.:
#			$ make images GLUON_RELEASE=23.42+5
#		would generate images named like this:
#			gluon-ff%site_code%-23.42+5-%router_model%.bin

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)

# Default priority for updates.
GLUON_PRIORITY ?= 0
