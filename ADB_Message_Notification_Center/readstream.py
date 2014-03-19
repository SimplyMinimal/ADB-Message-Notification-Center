from subprocess import Popen, PIPE
#Set Global Name
PROGRAM_NAME = "ADB Message Notification Center"

#Relaunches ADB in event of device disconnect
def _ReLaunch():
    print "[+] Relaunching..."
    (stdout, stderr) = Popen(["ls","-la"], stdout=PIPE).communicate()
    print stdout

if __name__ == "__main__":
    print "-=="+PROGRAM_NAME+"==-"
    _ReLaunch()
