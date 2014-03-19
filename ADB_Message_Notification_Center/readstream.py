from subprocess import Popen, PIPE

def _ReLaunch():
    print "[+] Relaunching..."
    (stdout, stderr) = Popen(["ls","-la"], stdout=PIPE).communicate()
    print stdout

_ReLaunch()
