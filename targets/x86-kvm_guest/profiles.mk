$(eval $(call GluonProfile,KVM,kmod-virtio-balloon kmod-virtio-net kmod-virtio-random))
$(eval $(call GluonProfileFactorySuffix,KVM,-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,KVM,-ext4,.img.gz))
$(eval $(call GluonModel,KVM,combined,x86-kvm))
