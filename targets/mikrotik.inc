-- Mikrotik images are netbooted via TFTP, then persisted with sysupgrade
defaults {
	factory = '-initramfs-kernel'
}

config('TARGET_ROOTFS_INITRAMFS', true)
config('TARGET_INITRAMFS_COMPRESSION_LZMA', true)
