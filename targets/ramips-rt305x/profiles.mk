# List of hardware profiles

# VoCore
$(eval $(call GluonProfile,VOCORE))
$(eval $(call GluonProfileFactorySuffix,VOCORE))
$(eval $(call GluonModel,VOCORE,vocore,vocore))

# FON2303A
$(eval $(call GluonProfile,FONERA20N))
$(eval $(call GluonProfileFactorySuffix,FONERA20N))
$(eval $(call GluonModel,FONERA20N,fonera20n,fon2303a))
