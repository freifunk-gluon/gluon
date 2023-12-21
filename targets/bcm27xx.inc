-- We do not use the ext4 images, so we do not want to build them.
config('TARGET_ROOTFS_EXT4FS', false)

defaults {
	factory_ext = '.img.gz',
	sysupgrade_ext = '.img.gz',
}
