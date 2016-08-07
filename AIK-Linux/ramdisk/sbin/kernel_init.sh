#!/system/bin/sh

# Set SELinux permissive by default
setenforce 0

# Mount root as RW to apply tweaks and settings
mount -t rootfs -o remount,rw rootfs
mount -o remount,rw /system
mount -o remount,rw /data

# Make internal storage directory.
if [ ! -d /data/prometheus ]; then
	mkdir /data/prometheus
fi;

# Synapse
chmod 666 /sys/module/workqueue/parameters/power_efficient
chmod -R 755 /res/*
ln -fs /res/synapse/uci /sbin/uci
/sbin/uci

# default kernel params
/sbin/kernel_params.sh

# systemless xposed
if [ -f "/data/xposed.img" ]; then
        mkdir /xposed
	mount ext4 loop@/data/xposed.img /xposed noatime
	exec /xposed/bind_mount.sh
fi;

# init.d support
if [ ! -e /system/etc/init.d ]; then
   mkdir /system/etc/init.d
   chown -R root.root /system/etc/init.d
   chmod -R 755 /system/etc/init.d
fi

# start init.d
for FILE in /system/etc/init.d/*; do
   sh $FILE >/dev/null
done;

