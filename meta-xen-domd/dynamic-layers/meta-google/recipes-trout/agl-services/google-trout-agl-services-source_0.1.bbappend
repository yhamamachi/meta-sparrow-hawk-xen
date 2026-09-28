# Sources are unpacked into UNPACKDIR since Yocto 5.1
S = "${UNPACKDIR}/${FETCH_CODE_PREFIX}"

# WORKDIR holds the sources shared with the other agl-services recipes,
# so rm_work must not remove it
RM_WORK_EXCLUDE += "${PN}"
