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

if [ $PARAM == "3" || $PARAM == "1" ]; then
  rm -f magisk.img
  rm -f stock_boot.img

  rm -rf /data/app/com.topjohnwu.magisk-*
  rm -rf /data/data/com.topjohnwu.magisk

  rm -rf /data/app/me.phh.superuser-*
  rm -rf /data/data/me.phh.superuser

  rm -f /data/app/Magisk*.apk
fi

if [ $PARAM == "2" || $PARAM == "1" ]; then
  rm -f su.img
  rm -f stock_boot*.gz

  rm -rf /data/app/eu.chainfire.supersu-*
  rm -rf /data/data/eu.chainfire.supersu

  rm -f /data/app/Super*.apk
fi

