#!/sbin/sh
mount /system;
if [ ! -d /system/aroma ]; then
	mkdir /system/aroma;
fi
cp -f /tmp/aroma-data/pr_*.prop /system/aroma/;
umount /system;
exit 0
