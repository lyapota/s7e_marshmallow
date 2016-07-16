#!/sbin/sh
# AIK-mobile/cleanup: reset working directory
# osm0sis @ xda-developers

aik=/tmp/AIK;

cd "$aik";
rm -rf ramdisk split_img *new.*;
echo "Working directory cleaned.";
return 0;

