$(eval $(call GluonTarget,armsr,armv7))
$(eval $(call GluonTarget,armsr,armv8))
$(eval $(call GluonTarget,ath79,generic))
$(eval $(call GluonTarget,ath79,nand))
$(eval $(call GluonTarget,ath79,mikrotik))
$(eval $(call GluonTarget,bcm27xx,bcm2708))
$(eval $(call GluonTarget,bcm27xx,bcm2709))
$(eval $(call GluonTarget,ipq40xx,generic))
$(eval $(call GluonTarget,ipq40xx,mikrotik))
$(eval $(call GluonTarget,ipq806x,generic))
$(eval $(call GluonTarget,lantiq,xrx200))
$(eval $(call GluonTarget,lantiq,xrx200_legacy))
$(eval $(call GluonTarget,lantiq,xway))
$(eval $(call GluonTarget,mediatek,filogic))
$(eval $(call GluonTarget,mediatek,mt7622))
$(eval $(call GluonTarget,mpc85xx,p1010))
$(eval $(call GluonTarget,mpc85xx,p1020))
$(eval $(call GluonTarget,ramips,mt7620))
$(eval $(call GluonTarget,ramips,mt7621))
$(eval $(call GluonTarget,ramips,mt76x8))
$(eval $(call GluonTarget,rockchip,armv8))
$(eval $(call GluonTarget,sunxi,cortexa7))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,geode))
$(eval $(call GluonTarget,x86,legacy))
$(eval $(call GluonTarget,x86,64))


ifeq ($(BROKEN),1)
$(eval $(call GluonTarget,bcm27xx,bcm2710)) # BROKEN: Untested
$(eval $(call GluonTarget,bcm27xx,bcm2711)) # BROKEN: No 11s support, no reset button, sys LED issues
$(eval $(call GluonTarget,kirkwood,generic)) # BROKEN: No devices with 11s support
$(eval $(call GluonTarget,mvebu,cortexa9)) # BROKEN: No 11s support
endif
