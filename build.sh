#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work
mkdir -p ${WORK_DIR}
USING_DOMA=no
USING_DOMU=no
USE_GRAPHICS_PACKAGE=yes
ENABLE_VIRTIO=no
ENABLE_DOMU_VIRTIO=no
ANDROID_VERSION=15

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -a | --doma:            Using DomA(Default is disable. Virtio is forcely enabled.)"
    echo "    -u | --domu:            Using DomU(Default is disable)"
    echo "    -v | --virtio:          Enable Virtio backend on DomD(Default is disabled)"
    echo "    -A | --android-version <15|16|17>: AAOS version to build for DomA(Default is 15)"
    echo "    -h | --help:            Show this usage"
}

# Proc arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--doma)
            USING_DOMA=yes; ENABLE_VIRTIO=yes ;;
        -u|--domu)
            USING_DOMU=yes ;;
        -v|--virtio)
            ENABLE_VIRTIO=yes ;;
        -A|--android-version)
            ANDROID_VERSION=$2
            shift ;;
        -h|--help)
            Usage; exit 0 ;;
        *) echo -e "\e[31mERROR: Unsupported option: $1\e[m"; Usage; exit 1 ;;
    esac
    shift
done
if [[ "${USING_DOMU}" == "yes" ]] && [[ "${ENABLE_VIRTIO}" == "yes" ]]; then
    ENABLE_DOMU_VIRTIO=yes
fi

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

# repo command setup
if [[ ${USING_DOMA} == "yes" ]]; then
    curl https://storage.googleapis.com/git-repo-downloads/repo > repo
    chmod a+x ./repo
    export PATH=$PWD:$PATH
fi

rm -rf yocto/build-dom*/conf
moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --ENABLE_ANDROID ${USING_DOMA} \
    --ENABLE_DOMU ${USING_DOMU} \
    --ENABLE_DOMU_VIRTIO ${ENABLE_DOMU_VIRTIO} \
    --USE_GRAPHICS_PACKAGE ${USE_GRAPHICS_PACKAGE} \
    --ENABLE_VIRTIO ${ENABLE_VIRTIO} \
    --ANDROID_VERSION ${ANDROID_VERSION} \
    --ADD_META_TEST yes \

ninja
if [[ "${USING_DOMA}" == "yes" ]]; then
    ninja full.img.gz android_only.img.gz
else
    ninja full.img.gz
fi

