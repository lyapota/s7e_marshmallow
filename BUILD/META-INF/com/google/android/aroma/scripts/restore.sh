#!/sbin/sh
mount /system;
	cp -f /system/aroma/pr_*.prop /tmp/aroma-data;
	rm -f /system/aroma/pr_*.prop;
umount /system;
exit 0
