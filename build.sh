#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}
USING_DOMU=no
CLEAN_BUILD_TEST=no

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -c: Clean Build test(Default is disable)"
    echo "    -u: Using DomU(Default is disable)"
    echo "    -h: Show this usage"
}

# Proc arguments
OPTIND=1
while getopts "chu" OPT
do
    case $OPT in
        c) CLEAN_BUILD_TEST=yes;;
        u) USING_DOMU=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

if [[ "${CLEAN_BUILD_TEST}" == "yes" ]]; then
    sed -i -e 's/"yocto"/"yocto-clean"/' ./prod-devel-rcar4_new.yaml
    rm -rf yocto-clean/build-dom*/conf
    rm -rf ./yocto-clean/build-dom*
fi

rm -rf yocto/build-dom*/conf
moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --ENABLE_DOMU ${USING_DOMU} \
    --ADD_META_TEST yes \

ninja fetch-domd
# Fix meta-sparrow-hawk layer for kirkstone
sed -i -e 's/"scarthgap"/"kirkstone scarthgap"/' yocto/meta-sparrow-hawk/conf/layer.conf
if [[ "${CLEAN_BUILD_TEST}" == "yes" ]]; then
    sed -i -e 's/"scarthgap"/"kirkstone scarthgap"/' yocto-clean/meta-sparrow-hawk/conf/layer.conf
fi

ninja
ninja full.img.gz
