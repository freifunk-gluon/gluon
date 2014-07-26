$(eval $(call GluonTarget,ar71xx,generic))

ifneq ($(BROKEN),)
$(eval $(call GluonTarget,x86,generic))
endif
