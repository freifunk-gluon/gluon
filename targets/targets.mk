$(eval $(call GluonTarget,ar71xx,generic))

ifeq ($(BROKEN),1)
$(eval $(call GluonTarget,x86,generic))
endif
