FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    sed -i ${D}/etc/xdg/weston/weston.ini \
        -e '$a shell=kiosk-shell.so' \
        -e '$a [output]' \
        -e '$a name=DP-1' \
        -e '$a app-ids=DomU' \
        -e '$a [output]' \
        -e '$a name=DSI-1' \
        -e '$a app-ids=DomA' \

    sed -i ${D}/${libdir}/systemd/system/weston.service \
        -e 's|/usr/bin/weston|/usr/bin/weston --debug --log=/tmp/weston|'

    # seatd binds the seat to the foreground VT, which is tty1 at boot.
    # getty@tty1 (Type=idle) resets tty1 to text mode after weston started
    # and the console hides weston, so switch to weston's own VT first.
    sed -i ${D}/${libdir}/systemd/system/weston.service \
        -e '/^ExecStart=/i ExecStartPre=+/usr/bin/chvt 7'
}

RDEPENDS:${PN} += "kbd"

