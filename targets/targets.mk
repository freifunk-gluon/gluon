$(eval $(call GluonTarget,ar71xx,generic))
$(eval $(call GluonTarget,ar71xx,tiny,generic))
$(eval $(call GluonTarget,ar71xx,nand))
$(eval $(call GluonTarget,brcm2708,bcm2708))
$(eval $(call GluonTarget,brcm2708,bcm2709))
$(eval $(call GluonTarget,mpc85xx,generic))
$(eval $(call GluonTarget,ramips,mt7621))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,geode))
$(eval $(call GluonTarget,x86,64))

ifneq ($(BROKEN),)
  AP_11S=1
$(eval $(call GluonTarget,ar71xx,mikrotik)) # BROKEN: no sysupgrade support
$(eval $(call GluonTarget,brcm2708,bcm2710)) # BROKEN: Untested
$(eval $(call GluonTarget,ipq806x)) # BROKEN: Untested
$(eval $(call GluonTarget,mvebu)) # BROKEN: No AP+IBSS or 11s support
$(eval $(call GluonTarget,sunxi)) # BROKEN: Untested
endif

ifeq ($(GLUON_WLAN_MESH),11s)
  AP_11S=1
endif

ifneq ($(AP_11S),)
$(eval $(call GluonTarget,ramips,mt7620)) # BROKEN: No AP+IBSS support
$(eval $(call GluonTarget,ramips,mt7628)) # BROKEN: No AP+IBSS support
$(eval $(call GluonTarget,ramips,rt305x)) # BROKEN: No AP+IBSS support
endif
