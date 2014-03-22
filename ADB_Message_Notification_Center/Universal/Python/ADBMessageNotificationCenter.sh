#!/bin/bash
#Start ADB and parser
echo "--==ADB Message Notification Center==--"
echo "Running..."
adb logcat -C -v long *:V|python adbread1.py > /dev/null
