#!/bin/bash
echo "-=ADB Logcat Verbose=-"
echo "Awaiting output..."
while [ 1 ];do
	adb logcat -C -v long *:V
done
