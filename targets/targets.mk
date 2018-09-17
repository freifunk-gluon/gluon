GLUON_WLAN_MESH_11s := $(filter 11s,$(GLUON_WLAN_MESH))

$(eval $(call GluonTarget,ar71xx,generic))
$(eval $(call GluonTarget,ar71xx,tiny))
$(eval $(call GluonTarget,ar71xx,nand))
$(eval $(call GluonTarget,brcm2708,bcm2708))
$(eval $(call GluonTarget,brcm2708,bcm2709))
$(eval $(call GluonTarget,mpc85xx,generic))
$(eval $(call GluonTarget,ramips,mt7621))
$(eval $(call GluonTarget,sunxi,cortexa7))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,geode))
$(eval $(call GluonTarget,x86,64))

ifneq ($(GLUON_WLAN_MESH_11s)$(BROKEN),)
$(eval $(call GluonTarget,ipq40xx))
$(eval $(call GluonTarget,ramips,mt7620))
$(eval $(call GluonTarget,ramips,rt305x))
endif

ifneq ($(BROKEN),)
$(eval $(call GluonTarget,ar71xx,mikrotik)) # BROKEN: no sysupgrade support
$(eval $(call GluonTarget,brcm2708,bcm2710)) # BROKEN: Untested
$(eval $(call GluonTarget,ipq806x)) # BROKEN: unstable wifi drivers
$(eval $(call GluonTarget,mvebu,cortexa9)) # BROKEN: No AP+IBSS or 11s support
$(eval $(call GluonTarget,ramips,mt76x8)) # BROKEN: unstable WiFi
endif
