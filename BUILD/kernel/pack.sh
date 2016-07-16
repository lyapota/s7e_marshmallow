#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

echo "pack boot.img"
cd /tmp/AIK

chmod 755 repackimg.sh;
./repackimg.sh

mv -f /tmp/AIK/image-new.img /tmp/boot.img
cd /tmp

#Remove SEANDROID ENFORCING Message
echo -n "SEANDROIDENFORCE" >> boot.img

echo "patch build.prop"
/tmp/busybox sed -i /timaversion/d /system/build.prop
/tmp/busybox sed -i /security.mdpp.mass/d /system/build.prop
/tmp/busybox sed -i /ro.hardware.keystore/d /system/build.prop
