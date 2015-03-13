$(eval $(call GluonTarget,ar71xx,generic))
$(eval $(call GluonTarget,ar71xx,nand))
$(eval $(call GluonTarget,mpc85xx,generic))
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,x86,kvm_guest))

ifneq ($(BROKEN),)
$(eval $(call GluonTarget,ramips,rt305x))
endif
