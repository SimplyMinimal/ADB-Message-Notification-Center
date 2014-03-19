#!/usr/bin/python
from subprocess import Popen, PIPE
from datetime import datetime
import objc
from Foundation import *
from AppKit import *
from PyObjCTools import AppHelper

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

class TrayStatusBar(NSApplication):

    def finishLaunching(self):
        # Make statusbar item
        statusbar = NSStatusBar.systemStatusBar()
        self.statusitem = statusbar.statusItemWithLength_(NSVariableStatusItemLength)
        self.icon = NSImage.alloc().initByReferencingFile_('Notify.ico')
        self.icon.setScalesWhenResized_(True)
        self.icon.setSize_((20, 20))
        self.statusitem.setImage_(self.icon)

        #make the menu
        self.menubarMenu = NSMenu.alloc().init()

        self.menuItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Click Me', 'clicked:', '')
        self.menubarMenu.addItem_(self.menuItem)

        self.quit = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Quit', 'terminate:', '')
        self.menubarMenu.addItem_(self.quit)

        #add menu to statusitem
        self.statusitem.setMenu_(self.menubarMenu)
        self.statusitem.setToolTip_('My App')

    def clicked_(self, notification):
        NSLog('clicked!')


if __name__ == "__main__":
    print "-=="+PROGRAM_NAME+"==-"
    print "Start Time: "+_NowTime()
    app = TrayStatusBar.sharedApplication()
    AppHelper.runEventLoop()
    _ReLaunch()

