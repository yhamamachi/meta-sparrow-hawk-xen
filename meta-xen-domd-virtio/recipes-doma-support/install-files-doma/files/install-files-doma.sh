#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd /dev/shm

# Wait for DomA network is active, then connect ADB via TCP
DOMA_IP="192.168.2.4"
while ! ping -c 1 -W 1 $DOMA_IP; do
    echo "Waiting for $DOMA_IP to be reachable..."
    sleep 1
done
adb connect $DOMA_IP:5555

for apk in $(ls /usr/bin/apks/*.apk); do
    adb install $apk
done
adb shell sync

echo "apk files are installed"

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

adb shell mkdir -p /data/system/devices/idc
adb push tablet.idc /data/system/devices/idc/Vendor_0627_Product_0003.idc
adb shell chown system:system -R /data/system/devices
adb shell chmod 644 -R /data/system/devices/idc/*.idc
adb shell sync
adb reboot

echo "idc files are installed. Rebooting."

