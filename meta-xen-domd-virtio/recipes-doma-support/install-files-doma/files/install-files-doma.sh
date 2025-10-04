#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd /dev/shm

# Wait for DomA network is active, then connect ADB via TCP
DOMA_IP="192.168.0.54"
while ! ping -c 1 -W 1 $DOMA_IP; do
    echo "Waiting for $DOMA_IP to be reachable..."
    sleep 1
done
adb connect $DOMA_IP:5555
adb root

if [[ $(adb shell ls /data/system/devices/idc 2>&1 > /dev/null ; echo $?) -eq 0 ]]; then
    echo "idc files has been already installed"
    exit
fi

cat << EOS > tablet.idc
touch.deviceType = touchScreen
#touch.deviceType = pointer
touch.gestureMode = spots
#touch.gestureMode = pointer
touch.orientationAware = 1
touch.toolSize.calibration = default
touch.pressure.calibration = default
touch.size.calibration = default
touch.orientation.calibration = none
device.internal = 1
EOS

cat << EOS > wacom_fhd.idc
touch.deviceType = touchScreen
touch.rawTouchAxes.x.max = 1920
touch.rawTouchAxes.y.max = 1080
EOS

adb shell mkdir -p /data/system/devices/idc
adb push tablet.idc /data/system/devices/idc/Vendor_0627_Product_0003.idc
adb push tablet.idc /data/system/devices/idc/Vendor_0627_Product_0001.idc
adb push wacom_fhd.idc /data/system/devices/idc/Wacom_Penpartner_Pen.idc
adb shell chown system:system -R /data/system/devices
adb shell chmod 644 -R /data/system/devices/idc/*.idc
for apk in $(ls /usr/bin/apks/*.apk); do
    adb install $apk
done
adb shell sync
adb reboot

echo "idc files are installed"

