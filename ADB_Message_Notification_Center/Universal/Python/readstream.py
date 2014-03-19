#!/usr/bin/python
from subprocess import Popen, PIPE
from datetime import datetime

#Set Global Name
PROGRAM_NAME = "ADB Message Notification Center"

#Relaunches ADB in event of device disconnect
def _ReLaunch():
    print "[+] Relaunching..."
    (stdout, stderr) = Popen(["adb","logcat -b radio"], stdout=PIPE).communicate()
    print stdout

def _NowTime():
    i = datetime.now()
    return i.strftime('%I:%M:%S %p  %m/%d/%Y')

if __name__ == "__main__":
    print "-=="+PROGRAM_NAME+"==-"
    print "Start Time: "+_NowTime()
    _ReLaunch()
