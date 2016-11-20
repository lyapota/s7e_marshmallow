#!/sbin/sh
# ========================================
# script Helios ROM
# ========================================
# Created by lyapota

# Remove SU images
cd /data
rm -f magisk.img
rm -f stock_boot.img
rm -f su.img
rm -f stock_boot*.gz

rm -rf /data/app/eu.chainfire.supersu-*
rm -rf /data/data/eu.chainfire.supersu

rm -rf /data/app/com.topjohnwu.magisk-*
rm -rf /data/data/com.topjohnwu.magisk

rm -rf /data/app/me.phh.superuser-*
rm -rf /data/data/me.phh.superuser

rm -f /data/app/Super*.apk
rm -f /data/app/Magisk*.apk

