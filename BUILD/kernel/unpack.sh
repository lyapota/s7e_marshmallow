#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

cd /tmp
echo "unpack boot.img"
/tmp/bbootimg -x boot.img bootimg.cfg zImage initrd.img second.img dt.img

echo "unpack ramdisk content"
  mkdir initrd
  cd initrd
  cat /tmp/initrd.img | gunzip | cpio -vid
