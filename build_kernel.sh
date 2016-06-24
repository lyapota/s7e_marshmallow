#!/bin/bash
# Jesse kernel build script v0.2
# modified by lyapota

MODEL=$1

if [ x$1 = x ]
then MODEL=hero2lte
fi

VARIANT=xx
ARCH=arm64

BUILD_WHERE=$(pwd)
BUILD_KERNEL_DIR=$BUILD_WHERE
BUILD_ROOT_DIR=$BUILD_KERNEL_DIR/..
BUILD_KERNEL_OUT_DIR=$BUILD_ROOT_DIR/kernel_out/KERNEL_OBJ
PRODUCT_OUT=$BUILD_ROOT_DIR/kernel_out

BUILD_CROSS_COMPILE=/home/lyapota/kernel/toolchain/aarch64-linux-gnu-5.3/bin/aarch64-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export PATH=$(pwd)/bin:$PATH
KERNEL_DEFCONFIG=exynos8890-lyapota_defconfig

KERNEL_VERSION="0.3"
KERNEL_NAME="-lyapota-kernel"
export LOCALVERSION=${KERNEL_NAME}-v${KERNEL_VERSION}


if [ $MODEL != hero2lte ]
then MODEL_DEFCONFIG=exynos8890-"$MODEL"_defconfig
fi

KERNEL_IMG=$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/Image
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
esac

FUNC_CLEAN_DTB()
{
	if ! [ -d $BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dts ] ; then
		echo "no directory : "$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dts""
	else
		echo "rm files in : "$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dts/*.dtb""
		rm $BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dts/*.dtb
		echo "rm files in : "$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dtb/*""
		rm -f $BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dtb/*
	fi
}

INSTALLED_DTIMAGE_TARGET=${PRODUCT_OUT}/dt.img
DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbtool
PAGE_SIZE=2048
DTB_PADDING=0

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

if [ $MODEL != hero2lte ]
then
	cp -f $BUILD_KERNEL_DIR/arch/arm64/configs/$KERNEL_DEFCONFIG /tmp/tmp_defconfig
	cat $BUILD_KERNEL_DIR/arch/arm64/configs/$MODEL_DEFCONFIG >> /tmp/tmp_defconfig

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=arm64 \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			tmp_defconfig || exit -1
else
	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=arm64 \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	cp $BUILD_KERNEL_OUT_DIR/.config $BUILD_KERNEL_DIR/arch/arm64/configs/$KERNEL_DEFCONFIG
fi

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=arm64 \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	cp $KERNEL_IMG $BUILD_KERNEL_DIR/output/Image-$MODEL
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

IMAGE_KITCHEN_DIR=$BUILD_ROOT_DIR/AIK-Linux
BOOT_IMAGE_TARGET=$IMAGE_KITCHEN_DIR/boot.img

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
                   rm -f $IMAGE_KITCHEN_DIR/image-new.img

	chmod a+r $BOOT_IMAGE_TARGET
	ls -l $BOOT_IMAGE_TARGET

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_BOOT_IMAGE"
	echo "================================="
	echo ""
}


ZIP_FILE_DIR=$BUILD_ROOT_DIR/BUILD
ZIP_NAME=G935F-lyapota-KERNEL-v$KERNEL_VERSION.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME

FUNC_PACK_ZIP_FILE()
{
	echo ""
	echo "================================="
	echo "START : FUNC_PACK_ZIP_FILE"
	echo "================================="
	echo ""
	echo "ZIP file target : $ZIP_FILE_TARGET"

	rm -f $ZIP_FILE_DIR/boot.img
	rm -f $ZIP_FILE_TARGET
	cp $BOOT_IMAGE_TARGET $ZIP_FILE_DIR

	cd $ZIP_FILE_DIR

	echo "Packing boot.img..."
	zip -gq $ZIP_NAME -r META-INF/ -x "*~"
	zip -gq $ZIP_NAME -r mcRegistry/ -x "*~" 
	zip -gq $ZIP_NAME boot.img

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
