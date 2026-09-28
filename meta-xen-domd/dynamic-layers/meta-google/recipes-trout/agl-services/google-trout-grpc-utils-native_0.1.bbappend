# The shared sources are unpacked into UNPACKDIR (sources/) of
# google-trout-agl-services-source since Yocto 5.1
S = "${TMPDIR}/work-shared/google-trout-agl-services-source/${PV}-${PR}/sources/${FETCH_CODE_PREFIX}"

# Bundled third party projects require CMake < 3.5 compatibility,
# which has been removed from CMake 4
EXTRA_OECMAKE += "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
