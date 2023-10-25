$(eval $(call GluonTarget,ath79,generic))
$(eval $(call GluonTarget,ath79,nand))
$(eval $(call GluonTarget,ath79,mikrotik))
$(eval $(call GluonTarget,bcm27xx,bcm2708))
$(eval $(call GluonTarget,bcm27xx,bcm2709))
$(eval $(call GluonTarget,ipq40xx,generic))
$(eval $(call GluonTarget,ipq40xx,mikrotik))
$(eval $(call GluonTarget,ipq806x,generic))
$(eval $(call GluonTarget,ipq807x,generic))
$(eval $(call GluonTarget,lantiq,xway))
$(eval $(call GluonTarget,mediatek,filogic))
$(eval $(call GluonTarget,mediatek,mt7622))
$(eval $(call GluonTarget,mpc85xx,p1010))
$(eval $(call GluonTarget,mpc85xx,p1020))
$(eval $(call GluonTarget,ramips,mt7620))
$(eval $(call GluonTarget,ramips,mt7621))
$(eval $(call GluonTarget,ramips,mt76x8))
$(eval $(call GluonTarget,realtek,rtl838x))
$(eval $(call GluonTarget,rockchip,armv8))
$(eval $(call GluonTarget,sunxi,cortexa7))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,geode))
$(eval $(call GluonTarget,x86,legacy))
$(eval $(call GluonTarget,x86,64))


ifneq ($(BROKEN),)
$(eval $(call GluonTarget,bcm27xx,bcm2710)) # BROKEN: Untested
$(eval $(call GluonTarget,lantiq,xrx200)) # BROKEN: Switch driver broken on Linux 5.15
$(eval $(call GluonTarget,mvebu,cortexa9)) # BROKEN: No 11s support
endif
