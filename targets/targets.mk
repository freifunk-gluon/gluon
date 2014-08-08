$(eval $(call GluonTarget,ar71xx,generic))
$(eval $(call GluonTarget,mpc85xx,generic))

ifneq ($(BROKEN),)
$(eval $(call GluonTarget,x86,generic))
endif
