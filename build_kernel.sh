#!/bin/bash
# Prometheus kernel for Samsung Galaxy S7 build script by lyapota

##################### VARIANTS #####################
#
# xx   = International Exynos & Duos, Canadian Exynos
#        SM-G930F, SM-G930FD, SM-G930X, SM-G930W8
#        SM-G935F, SM-G935FD, SM-G935X, SM-G935W8
#
# kor  = Korean Exynos
#        SM-G930K, SM-G930L, SM-G930S
#
###################### CONFIG ######################

[ "$1" ] && MODEL=herolte
[ "$MODEL" ] || MODEL=hero2lte
[ "$2" ] && VARIANT=$2
[ "$VARIANT" ] || VARIANT=xx

ARCH=arm64

BUILD_WHERE=$(pwd)
BUILD_KERNEL_DIR=$BUILD_WHERE
BUILD_ROOT_DIR=$BUILD_KERNEL_DIR/..
BUILD_KERNEL_OUT_DIR=$BUILD_ROOT_DIR/kernel_out/KERNEL_OBJ-"$MODEL"

BUILD_CROSS_COMPILE=/home/lyapota/kernel/toolchain/aarch64-linux-gnu-5.3/bin/aarch64-
# BUILD_CROSS_COMPILE=/home/lyapota/kernel/toolchain/linaro-64/bin/aarch64-linux-android-
# BUILD_CROSS_COMPILE=/home/lyapota/kernel/toolchain/aarch64-sabermod-7.0/bin/aarch64-

BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export PATH=$(pwd)/bin:$PATH

KERNEL_VERSION="1.6.0"
KERNEL_NAME="-prometheus"
export LOCALVERSION=${KERNEL_NAME}-v${KERNEL_VERSION}

KERNEL_DEFCONFIG=exynos8890-lyapota_defconfig
MODEL_DEFCONFIG=exynos8890-lyapota-"$MODEL"

KERNEL_IMG=$BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/Image
DTC=$BUILD_KERNEL_OUT_DIR/scripts/dtc/dtc

case $MODEL in
herolte)
	case $VARIANT in
	can|eur|xx|duos)
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
		;;
	kor|skt|ktt|lgt)
		DTSFILES="exynos8890-herolte_kor_all_00 exynos8890-herolte_kor_all_01
				exynos8890-herolte_kor_all_02 exynos8890-herolte_kor_all_03
				exynos8890-herolte_kor_all_04 exynos8890-herolte_kor_all_08"
		;;
	*) abort "Unknown variant: $VARIANT" ;;
	esac
	;;
hero2lte)
	case $VARIANT in
	can|eur|xx|duos)
		DTSFILES="exynos8890-hero2lte_eur_open_00 exynos8890-hero2lte_eur_open_01
				exynos8890-hero2lte_eur_open_03 exynos8890-hero2lte_eur_open_04
				exynos8890-hero2lte_eur_open_08"
		;;
	kor|skt|ktt|lgt)
		DTSFILES="exynos8890-hero2lte_kor_all_00 exynos8890-hero2lte_kor_all_01
				exynos8890-hero2lte_kor_all_03 exynos8890-hero2lte_kor_all_04
				exynos8890-hero2lte_kor_all_08"
		;;
	*) abort "Unknown variant: $VARIANT" ;;
	esac
	;;
*) abort "Unknown device: $DEVICE" ;;
esac


INSTALLED_DTIMAGE_TARGET=${BUILD_KERNEL_OUT_DIR}/dt.img
DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbtool
PAGE_SIZE=2048
DTB_PADDING=0

FUNC_CLEAN_DTB()
{
	if ! [ -d $BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dts""
	else
		rm -f $BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dtb/*
		rm $BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/boot.img-dtb
	fi
}

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
	echo "================================="
	echo "START : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
	echo "DT image target : $INSTALLED_DTIMAGE_TARGET"

	mkdir -p "$BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dtb"
	cd "$BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dtb"
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		"${CROSS_COMPILE}cpp" -nostdinc -undef -x assembler-with-cpp -I "$BUILD_KERNEL_DIR/include" "$BUILD_KERNEL_DIR/arch/$ARCH/boot/dts/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTC -p $DTB_PADDING -i "$BUILD_KERNEL_DIR/arch/$ARCH/boot/dts" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo "Generating dtb.img..."
	"$DTBTOOL" -o "$INSTALLED_DTIMAGE_TARGET" -p "$BUILD_KERNEL_OUT_DIR/arch/$ARCH/boot/dtb/" -s $PAGE_SIZE

	chmod a+r $INSTALLED_DTIMAGE_TARGET

	cp $INSTALLED_DTIMAGE_TARGET $BUILD_KERNEL_DIR/output/dt-$MODEL.img

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build model="$MODEL""
        echo "build common config="$KERNEL_DEFCONFIG ""
	echo "build model config="$MODEL_DEFCONFIG ""

	mkdir -p $BUILD_KERNEL_DIR/output
	rm -f $KERNEL_IMG
	mkdir -p $BUILD_KERNEL_OUT_DIR/firmware
	rm -f $BUILD_KERNEL_OUT_DIR/firmware/apm_8890_evt1.h
	ln -s $BUILD_KERNEL_DIR/firmware/apm_8890_evt1.h $BUILD_KERNEL_OUT_DIR/firmware/apm_8890_evt1.h
	mkdir -p $BUILD_KERNEL_OUT_DIR/init
	rm -f $BUILD_KERNEL_OUT_DIR/init/vmm.elf
	ln -s $BUILD_KERNEL_DIR/init/vmm.elf $BUILD_KERNEL_OUT_DIR/init/vmm.elf

	cp -f $BUILD_KERNEL_DIR/arch/$ARCH/configs/$KERNEL_DEFCONFIG $BUILD_KERNEL_DIR/arch/$ARCH/configs/tmp_defconfig
	cat $BUILD_KERNEL_DIR/arch/$ARCH/configs/$MODEL_DEFCONFIG >> $BUILD_KERNEL_DIR/arch/$ARCH/configs/tmp_defconfig

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			tmp_defconfig || exit -1

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	cp $KERNEL_IMG $BUILD_KERNEL_DIR/output/Image-$MODEL
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

IMAGE_KITCHEN_DIR=$BUILD_KERNEL_DIR/AIK-Linux
BOOT_IMAGE_TARGET=$IMAGE_KITCHEN_DIR/boot-"$MODEL".img

FUNC_BUILD_BOOT_IMAGE()
{
	echo ""
	echo "================================="
	echo "START : FUNC_BUILD_BOOT_IMAGE"
	echo "================================="
	echo ""
	echo "BOOT image target : $BOOT_IMAGE_TARGET"

	rm -f $IMAGE_KITCHEN_DIR/split_img/boot.img-dtb
	rm -f $IMAGE_KITCHEN_DIR/split_img/boot.img-zImage
	rm -f $BOOT_IMAGE_TARGET
	cp $BUILD_KERNEL_DIR/output/dt-$MODEL.img  $IMAGE_KITCHEN_DIR/split_img/boot.img-dtb
	cp $BUILD_KERNEL_DIR/output/Image-$MODEL  $IMAGE_KITCHEN_DIR/split_img/boot.img-zImage

	echo "Generating boot.img..."
	cd "$IMAGE_KITCHEN_DIR"
	./repackimg.sh
	cp $IMAGE_KITCHEN_DIR/image-new.img $BOOT_IMAGE_TARGET

	#Remove SEANDROID ENFORCING Message
#	echo -n "SEANDROIDENFORCE" >> $BOOT_IMAGE_TARGET

	rm -f $IMAGE_KITCHEN_DIR/image-new.img

	if [ ! -f "$BOOT_IMAGE_TARGET" ]; then
		exit -1
	fi

	chmod a+r $BOOT_IMAGE_TARGET
	ls -l $BOOT_IMAGE_TARGET

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_BOOT_IMAGE"
	echo "================================="
	echo ""
}


ZIP_FILE_DIR=$BUILD_KERNEL_DIR/BUILD
ZIP_NAME=exynos8890-prometheus-v$KERNEL_VERSION.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME

FUNC_PACK_ZIP_FILE()
{
	echo ""
	echo "================================="
	echo "START : FUNC_PACK_ZIP_FILE"
	echo "================================="
	echo ""
	echo "ZIP file target : $ZIP_FILE_TARGET"

	rm -f $ZIP_FILE_DIR/kernel/boot-"$MODEL".img
	rm -f $ZIP_FILE_TARGET
	cp $BOOT_IMAGE_TARGET $ZIP_FILE_DIR/kernel

	cd $ZIP_FILE_DIR

	echo "Packing boot.img..."
        sed -i "s/ini_set(\"rom_version\",.*\".*\");/ini_set(\"rom_version\",          \"${KERNEL_VERSION}\");/g" META-INF/com/google/android/aroma-config

        export LC_TIME=en_US
        CURRENT_DATE=`date +"%d %B %Y"`
        sed -i "s/ini_set(\"rom_date\",.*\".*\");/ini_set(\"rom_date\",             \"${CURRENT_DATE}\");/g" META-INF/com/google/android/aroma-config

	zip -gq $ZIP_NAME -r META-INF/ -x "*~"
	zip -gq $ZIP_NAME -r system/ -x "*~" 
	zip -gq $ZIP_NAME -r kernel/ -x "*~" 

	if [ ! -f "$ZIP_FILE_TARGET" ]; then
		exit -1
	fi

	chmod a+r $ZIP_NAME
	ls -l $ZIP_NAME

	echo ""
	echo "================================="
	echo "END   : FUNC_PACK_ZIP_FILE"
	echo "================================="
	echo ""
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

    FUNC_CLEAN_DTB
    FUNC_BUILD_KERNEL
    FUNC_BUILD_DTIMAGE_TARGET
    FUNC_BUILD_BOOT_IMAGE
    FUNC_PACK_ZIP_FILE

    END_TIME=`date +%s`
	
    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log

if [ ! -f "$KERNEL_IMG" ]; then
  exit 1
fi
