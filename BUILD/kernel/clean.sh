#!/sbin/sh
# ========================================
# script Helios ROM
# ========================================
# Created by lyapota

PARAM=$1

if [ "$PARAM." == "." ]; then
  PARAM="1"
fi

# Remove SU images
cd /data

if [ $PARAM == "3" ] || [ $PARAM == "1" ]; then
  rm -rf /data/app/com.topjohnwu.magisk-*
  rm -rf /data/data/com.topjohnwu.magisk

  rm -rf /data/app/me.phh.superuser-*
  rm -rf /data/data/me.phh.superuser

  rm -rf /data/Magisk.apk
  rm -rf /cache/magisk.log /cache/last_magisk.log /cache/magiskhide.log \
       /cache/magisk /cache/magisk_merge /cache/magisk_mount /cache/unblock \
       /data/magisk.img /data/magisk_merge.img /data/stock_boot.img \
       /data/busybox /data/magisk /data/custom_ramdisk_patch.sh 2>/dev/null
fi

if [ $PARAM == "2" ] || [ $PARAM == "1" ]; then
  rm -rf /data/app/eu.chainfire.supersu-*
  rm -rf /data/data/eu.chainfire.supersu

  rm -f /data/SuperSU.apk
  rm -rf /data/su.img /data/stock_boot*.gz /data/supersu /supersu
fi

