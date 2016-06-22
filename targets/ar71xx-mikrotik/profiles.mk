# List of hardware profiles

## Mikrotik

# Will contain both ath5k and ath9k
# ath5k cards are commonly used with Mikrotik hardware
$(eval $(call GluonProfile,DefaultNoWifi,kmod-ath5k))
$(eval $(call GluonProfileFactorySuffix,DefaultNoWifi,,-rootfs.tar.gz,-vmlinux-lzma.elf))
$(eval $(call GluonProfileSysupgradeSuffix,DefaultNoWifi))
$(eval $(call GluonModel,DefaultNoWifi,DefaultNoWifi,mikrotik))
