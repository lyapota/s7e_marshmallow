#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

DIR_SEL=/tmp/aroma

get_sel()
{
  sel_file=$DIR_SEL/$1
  sel_value=`cat $sel_file | cut -d '=' -f2`
  echo $sel_value
}

if [ ! -e $DIR_SEL/pr_device.prop ]; then
	BOOT="boot.img"
else
	val1=`get_sel pr_device.prop`
        case $val1 in
        	1)
		  BOOT="boot-hero2lte.img"
        	  ;;
        	2)
		  BOOT="boot-herolte.img"
        	  ;;
        esac
fi

echo "unpack $BOOT"
mv -f /tmp/"$BOOT" /tmp/AIK/boot.img

cd /tmp/AIK
chmod 755 unpackimg.sh;
./unpackimg.sh boot.img
rm -f boot.img
