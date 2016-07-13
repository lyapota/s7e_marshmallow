#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

cd /tmp/initrd
echo "pack modified ramdisk"
find . | cpio --create --format='newc' | gzip > /tmp/newinitrd.img


################
## pack boot.img
cd /tmp
rm -f boot.img
echo "pack boot.img"
if [ -e /tmp/newinitrd.img ]; then
	/tmp/bbootimg --create boot.img -f bootimg.cfg -k zImage -r newinitrd.img -d dt.img
else
	/tmp/bbootimg --create boot.img -f bootimg.cfg -k zImage -r initrd.img -d dt.img  
fi

#Remove SEANDROID ENFORCING Message
echo -n "SEANDROIDENFORCE" >> boot.img

echo "patch build.prop"
/tmp/busybox sed -i /timaversion/d /system/build.prop
/tmp/busybox sed -i /security.mdpp.mass/d /system/build.prop
/tmp/busybox sed -i /ro.hardware.keystore/d /system/build.prop
