#!/bin/bash
echo "-=ADB Logcat Radio=-"
echo "Awaiting output..."
while [ 1 ];do
	adb logcat -C -b radio
done
