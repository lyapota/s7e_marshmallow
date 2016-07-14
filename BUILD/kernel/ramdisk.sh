#!/sbin/sh
# ========================================
# script Prometheus kernels
# ========================================
# Created by lyapota

DIR_SEL=/tmp/aroma
FILE_SCRIPT=/tmp/initrd/sbin/kernel_params.sh

get_sel()
{
  sel_file=$DIR_SEL/$1
  sel_value=`cat $sel_file | cut -d '=' -f2`
  echo $sel_value
}


if [ ! -e $DIR_SEL/pr_little_min.prop ]; then
	little_min="0"
else
	val1=`get_sel pr_little_min.prop`
        case $val1 in
        	1)
        	  little_min="338000"
        	  ;;
        	2)
        	  little_min="442000"
        	  ;;
        	3)
        	  little_min="546000"
        	  ;;
        	4)
        	  little_min="650000"
        	  ;;
        	5)
        	  little_min="754000"
        	  ;;
        esac
fi


if [ ! -e $DIR_SEL/pr_little_max.prop ]; then
	little_max="0"
else
	val1=`get_sel pr_little_max.prop`
        case $val1 in
        	1)
        	  little_max="1586000"
        	  ;;
        	2)
        	  little_max="1690000"
        	  ;;
        	3)
        	  little_max="1794000"
        	  ;;
        	4)
        	  little_max="1898000"
        	  ;;
        	5)
        	  little_max="1976000"
        	  ;;
        esac
fi


if [ ! -e $DIR_SEL/pr_big_min.prop ]; then
	big_min="0"
else
	val1=`get_sel pr_big_min.prop`
        case $val1 in
        	1)
        	  big_min="312000"
        	  ;;
        	2)
        	  big_min="416000"
        	  ;;
        	3)
        	  big_min="520000"
        	  ;;
        	4)
        	  big_min="624000"
        	  ;;
        	5)
        	  big_min="728000"
        	  ;;
        esac
fi


if [ ! -e $DIR_SEL/pr_big_max.prop ]; then
	big_max="0"
else
	val1=`get_sel pr_big_max.prop`
        case $val1 in
        	1)
        	  big_max="2496000"
        	  ;;
        	2)
        	  big_max="2600000"
        	  ;;
        	3)
        	  big_max="2704000"
        	  ;;
        	4)
        	  big_max="2808000"
        	  ;;
        	5)
        	  big_max="2912000"
        	  ;;
        esac
fi


if [ ! -e $DIR_SEL/pr_gpu_max.prop ]; then
	gpu_max="0"
else
	val1=`get_sel pr_gpu_max.prop`
        case $val1 in
        	1)
        	  gpu_max="546"
        	  ;;
        	2)
        	  gpu_max="600"
        	  ;;
        	3)
        	  gpu_max="650"
        	  ;;
        	4)
        	  gpu_max="702"
        	  ;;
        	5)
        	  gpu_max="806"
        	  ;;
        esac
fi


if [ ! -e $DIR_SEL/pr_reset_freq.prop ]; then
	reset_freq="10"
else
	val1=`get_sel pr_reset_freq.prop`
        case $val1 in
        	1)
        	  reset_freq="5"
        	  ;;
        	2)
        	  reset_freq="10"
        	  ;;
        	3)
        	  reset_freq="15"
        	  ;;
        esac
fi


echo -e "echo \"$little_min\" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;" >> $FILE_SCRIPT;
echo -e "echo \"$little_max\" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;" >> $FILE_SCRIPT;
echo -e "echo \"$big_min\" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq;" >> $FILE_SCRIPT;
echo -e "echo \"$big_max\" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq;" >> $FILE_SCRIPT;
echo -e "echo \"$gpu_max\" > /sys/devices/14ac0000.mali/max_clock;" >> $FILE_SCRIPT;
echo -e "echo \"$reset_freq\" > /sys/power/cpufreq_reset_limit_sec;" >> $FILE_SCRIPT;
cat $FILE_SCRIPT;
