#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}
USING_DOMU=no
USE_GRAPHICS_PACKAGE=no
CLEAN_BUILD_TEST=no

CheckGraphicsPackage () {
    PROP_DIR=$SCRIPT_DIR/proprietary
    ITEM_LIST=("GSX_KM_V4H_SparrowHawk.tar.bz2" "r8a779g3_linux_gsx_binaries_gles.tar.bz2")
    for item in ${ITEM_LIST[@]}; do
        if [[ ! -e ${PROP_DIR}/${item} ]]; then
            echo "${PROP_DIR}/${item} is not found !!"
            exit -1
        fi
    done
}

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -c: Clean Build test(Default is disable)"
    echo "    -g: Use graphics package(Default is not used)"
    echo "    -u: Using DomU(Default is disable)"
    echo "    -h: Show this usage"
}

# Proc arguments
OPTIND=1
while getopts "cghu" OPT
do
    case $OPT in
        c) CLEAN_BUILD_TEST=yes;;
        g) USE_GRAPHICS_PACKAGE=yes;;
        u) USING_DOMU=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

# Check and copy graphics packages
if [[ ${USE_GRAPHICS_PACKAGE} == "yes" ]]; then
    CheckGraphicsPackage
fi

if [[ "${CLEAN_BUILD_TEST}" == "yes" ]]; then
    sed -i -e 's/"yocto"/"yocto-clean"/' ./prod-devel-rcar4_new.yaml
    rm -rf yocto-clean/build-dom*/conf
    rm -rf ./yocto-clean/build-dom*
fi

rm -rf yocto/build-dom*/conf
moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --ENABLE_DOMU ${USING_DOMU} \
    --USE_GRAPHICS_PACKAGE ${USE_GRAPHICS_PACKAGE} \
    --ADD_META_TEST yes \

ninja
ninja full.img.gz
