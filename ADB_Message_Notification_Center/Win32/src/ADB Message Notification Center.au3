#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=envelope.ico
#AutoIt3Wrapper_Outfile=ADB Message Notification Center.exe
#AutoIt3Wrapper_Res_Fileversion=3.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Date.au3>
#include <Constants.au3>
#include "Notify.au3"
#include <Misc.au3>

Global Const $PROGRAM_NAME = "ADB Message Notification Center"
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
$Start_Time = _Now()
ConsoleWrite("--Start Time: " & $Start_Time & @CRLF)
TraySetIcon("Notify.ico")
TraySetToolTip($PROGRAM_NAME & " (v" & FileGetVersion(@ScriptFullPath) & ")" & @CRLF & "No New Messages")
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "Terminate")

If _Singleton($PROGRAM_NAME, 1) == 0 Then
	MsgBox(48, $PROGRAM_NAME & " - Warning", "An occurence of " & @ScriptName & " is already running.")
	Exit
EndIf

; Register message for click event
_Notify_RegMsg()

; Set notification location
_Notify_Locate(0)

; Show notifications
Local $New_Message_Count = 0

ConsoleWrite("--Initializing..." & @CRLF)

$hSTDOUT = _ReLaunch()
_ReduceMemory()

Local $data, $Counter = 0
While True
	$Counter += 1
	If Not ProcessExists($hSTDOUT) Then $hSTDOUT = _ReLaunch()
	$data &= StdoutRead($hSTDOUT)
	If @error Then Sleep(25)
	If StringInStr($data, "< SMS_ACKNOWLEDGE") Then;Match Found
		$New_Message_Count += 1
		TraySetToolTip("Running since: " & $Start_Time & @CRLF & "New Message Counter: " & $New_Message_Count & @CRLF & "Last Message at " & _NowTime())
		_Notify_Set(0, Default, Default, "Courier New", False, 250)
		_Notify_Show(@ScriptDir & "\envelope.png", "", "New Message", 20)
	EndIf
	$data = ""
	If $Counter > 50 Then
		_ReduceMemory()
		$Counter = 0
	EndIf
	Sleep(300)
WEnd

Func _ReLaunch()
	ConsoleWrite("--Relaunching...")
	$hPID = Run(@ComSpec & " /c " & 'adb logcat -b radio', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	ConsoleWrite("[" & $hPID & "]" & @CRLF)
	Return $hPID
EndFunc   ;==>_ReLaunch

Func _CreateDefaultSettings()
	; Create an INI section structure as a string.
	$SMS_INI = "New SMS Message=< SMS_ACKNOWLEDGE"
	$Logcat_INI = "New TextPlus Message=Displayed com.gogii.textplus"

	; Write the string to the section labelled 'Radio'.
	IniWriteSection($INI_SETTINGS_FILE, "Radio", $SMS_INI)
	FileWrite($INI_SETTINGS_FILE, @CRLF)
	IniWriteSection($INI_SETTINGS_FILE, "Logcat", $Logcat_INI)
EndFunc   ;==>_CreateDefaultSettings



Func _ReduceMemory($i_PID = -1)
	If $i_PID <> -1 Then
		Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $i_PID)
		Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
		DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
	Else
		Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
	EndIf

	Return $ai_Return[0]
EndFunc   ;==>_ReduceMemory


Func Terminate()
	TraySetToolTip("Shutting Down...")
	StdioClose($hSTDOUT)
	Run("TaskKill /PID " & $hSTDOUT, @ScriptDir, @SW_HIDE)
	Exit
EndFunc   ;==>Terminate

