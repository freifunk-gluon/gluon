-- We do not use the ext4 images, so we do not want to build them.
config('TARGET_ROOTFS_EXT4FS', false)

defaults {
	factory = '-squashfs-combined-efi',
	factory_ext = '.img.gz',
	sysupgrade = '-squashfs-combined-efi',
	sysupgrade_ext = '.img.gz',
}
