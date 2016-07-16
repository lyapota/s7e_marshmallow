#!/system/bin/sh

BB=/system/xbin/busybox;

# Mount root as RW to apply tweaks and settings
$BB mount -o remount,rw /;
$BB mount -o remount,rw /system;

# Set SELinux permissive by default
setenforce 0

# Make internal storage directory.
if [ ! -d /data/prometheus ]; then
	mkdir /data/prometheus
fi;

# Synapse
$BB mount -t rootfs -o remount,rw rootfs
$BB chmod -R 755 /res/*
$BB ln -fs /res/synapse/uci /sbin/uci
/sbin/uci

# default kernel params
/sbin/kernel_params.sh

# Init.d
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/;
	chown -R root.root /system/etc/init.d;
	chmod 777 /system/etc/init.d/;
	chmod 777 /system/etc/init.d/*;
fi;
$BB run-parts /system/etc/init.d
