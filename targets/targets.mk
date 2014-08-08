$(eval $(call GluonTarget,ar71xx,generic))

ifneq ($(BROKEN),)
$(eval $(call GluonTarget,x86,generic))
$(eval $(call GluonTarget,mpc85xx,generic))
endif
