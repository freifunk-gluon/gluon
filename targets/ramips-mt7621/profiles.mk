# List of hardware profiles

$(eval $(call GluonProfile,Default))
$(eval $(call GluonModel,Default,dir-860l-b1,d-link-dir-860l-b1))

$(eval $(call GluonProfile,AC1200pro))
$(eval $(call GluonProfileFactorySuffix,AC1200pro))
$(eval $(call GluonModel,AC1200pro,ac1200pro,digineo-ac1200pro))
