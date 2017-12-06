#!/bin/bash


if [ -z "$DO_NOT_MOUNT" ]; then

	mkdir -p $CHROOT_PATH/proc $CHROOT_PATH/sys $CHROOT_PATH/dev
	mount -t proc proc $CHROOT_PATH/proc/
	mount -t sysfs sys $CHROOT_PATH/sys/
	mount -o bind /dev $CHROOT_PATH/dev/
	mount -o bind /dev/pts $CHROOT_PATH/dev/pts/

	mount --bind "/etc/hosts" "$CHROOT_PATH/etc/hosts"
	mount --bind "/etc/resolv.conf" "$CHROOT_PATH/etc/resolv.conf"


	IFS=: 
	for mount_paths in ${!MOUNT_PATHS_*}
	do
		mount_paths="${!mount_paths}"
		for mpath in ${mount_paths}
		do
			dpath="$CHROOT_PATH$mpath"
			mkdir -p "$dpath"
			mount --bind "$mpath" "$dpath"
		done
	done
	unset IFS	

	
fi
export MY_DOCKER_PWD="$PWD"


exec chroot $CHROOT_PATH "$DOCKER_DEV_HOME/scripts/chroot-entry.sh" "$@"


