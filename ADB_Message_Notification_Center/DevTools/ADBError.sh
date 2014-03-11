#!/bin/bash
echo "-=ADB Logcat Error Only=-"
echo "Awaiting output..."
while [ 1 ];do
	adb logcat -C -v long *:E
done
