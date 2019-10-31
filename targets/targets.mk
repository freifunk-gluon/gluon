$(eval $(call GluonTarget,ar71xx,generic))
ifneq ($(GLUON_DEPRECATED),0)
$(eval $(call GluonTarget,ar71xx,tiny))
endif
$(eval $(call GluonTarget,ar71xx,nand))
$(eval $(call GluonTarget,ath79,generic))
$(eval $(call GluonTarget,brcm2708,bcm2708))
$(eval $(call GluonTarget,brcm2708,bcm2709))
$(eval $(call GluonTarget,ipq40xx,generic))
$(eval $(call GluonTarget,ipq806x,generic))
$(eval $(call GluonTarget,lantiq,xway))
$(eval $(call GluonTarget,mpc85xx,generic))
$(eval $(call GluonTarget,mpc85xx,p1020))
$(eval $(call GluonTarget,ramips,mt7620))
$(eval $(call GluonTarget,ramips,mt7621))
$(eval $(call GluonTarget,ramips,mt76x8))
$(eval $(call GluonTarget,ramips,rt305x))
$(eval $(call GluonTarget,sunxi,cortexa7))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,geode))
$(eval $(call GluonTarget,x86,64))


ifneq ($(BROKEN),)
$(eval $(call GluonTarget,ar71xx,mikrotik)) # BROKEN: no sysupgrade support
$(eval $(call GluonTarget,brcm2708,bcm2710)) # BROKEN: Untested
$(eval $(call GluonTarget,mvebu,cortexa9)) # BROKEN: No 11s support
endif
