COMPATIBLE_MACHINE:append = "|sparrow-hawk"
SOC:r8a779g3 = "V4H"
SRC_URI:remove = " file://0000-Makefile-Disable-linker-warning.patch"
SRC_URI:append:r8a779g3 = " file://0001-HACK-v4h-Configure-IPMMU-registers.patch"
ATFW_CONF="SPD=none"

