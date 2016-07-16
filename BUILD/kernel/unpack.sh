#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

echo "unpack boot.img"
mv -f /tmp/boot.img /tmp/AIK

cd /tmp/AIK
chmod 755 unpackimg.sh;
./unpackimg.sh boot.img
rm -f boot.img
