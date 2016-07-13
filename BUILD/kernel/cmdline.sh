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

#############
## set vdd_uv
if [ ! -e $DIR_SEL/pr_vdd_uv.prop ]; then
	vdd_uv="vdd_uv=0"
else
	val1=`get_sel pr_vdd_uv.prop`
        case $val1 in

        	1)
        	  vdd_uv="vdd_uv=0"
        	  ;;
        	2)
        	  vdd_uv="vdd_uv=1"
        	  ;;
        	3)
        	  vdd_uv="vdd_uv=2"
        	  ;;
        	4)
        	  vdd_uv="vdd_uv=3"
        	  ;;
        	5)
        	  vdd_uv="vdd_uv=4"
        	  ;;
        esac
fi

############
##set kernel new command line
echo "patch kernel command line"
cd /tmp
/tmp/busybox sed -i "s/vdd_uv=0/$vdd_uv/" /tmp/zImage

