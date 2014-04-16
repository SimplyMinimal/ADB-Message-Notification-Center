#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Notify.ico
#AutoIt3Wrapper_Outfile=ADB Message Notification Center.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=This tool is useful for everyday use as well as development and testing purposes when debugging Android. It is easily customizable to display alerts for certain events.
#AutoIt3Wrapper_Res_Description=Displays notifications for ADB logs
#AutoIt3Wrapper_Res_Fileversion=3.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Date.au3>
#include <Constants.au3>
#include "Notify.au3"
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>

Local Const $PROGRAM_NAME = "ADB Message Notification Center"
Local Const $INI_SETTINGS_FILE = @ScriptDir & "\ADB_MNC_Settings.ini"
Local $aIcon = IniReadSection($INI_SETTINGS_FILE, "Icon"), $aLogcat, $aRadio;Holds icons, display messages, and match terms
Local $USE_LOGCAT = True, $USE_RADIO = True;Check flags so we run only what's needed based on ini settings
If Not FileExists($INI_SETTINGS_FILE) Then _CreateDefaultSettings()

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
TraySetClick(16)

$Start_Time = _Now()
ConsoleWrite("--Start Time: " & $Start_Time & @CRLF)
TraySetIcon("Notify.ico")
TraySetToolTip($PROGRAM_NAME & " (v" & FileGetVersion(@ScriptFullPath) & ")" & @CRLF & "No New Messages")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, 'ADB_MNC_FormMaximize')
TrayCreateItem("Configuration")
TrayItemSetOnEvent(-1, "ADB_MNC_FormMaximize")
TrayCreateItem("")
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "Terminate")

If _Singleton($PROGRAM_NAME, 1) == 0 Then
	MsgBox(48, $PROGRAM_NAME & " - Warning", "An occurrence of " & @ScriptName & " is already running.")
	Exit
EndIf

#Region ### START Koda GUI section ### Form=c:\users\km72044\documents\autoit\koda\adb message notification center.kxf
$ADB_MNC_Form = GUICreate("ADB Message Notification Center - Configuration", 597, 414, 202, 142)
GUISetIcon("Notify.ico")
GUISetOnEvent($GUI_EVENT_CLOSE, "ADB_MNC_FormClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "ADB_MNC_FormMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "ADB_MNC_FormMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "ADB_MNC_FormRestore")
$TabGroupControl = GUICtrlCreateTab(8, 8, 572, 344)
GUICtrlSetOnEvent(-1, "TabGroupControlChange")
$LogcatSheet = GUICtrlCreateTabItem("Logcat")
$Label1 = GUICtrlCreateLabel("Coming Soon...(Or later..)", 209, 169, 172, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Calibri")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$RadioSheet = GUICtrlCreateTabItem("Radio")
$Label2 = GUICtrlCreateLabel("Coming Soon...(Or later..)", 209, 169, 172, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Calibri")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$SummarySheet = GUICtrlCreateTabItem("Last Notifications")
GUICtrlSetState(-1, $GUI_SHOW)
$Label4 = GUICtrlCreateLabel("Coming Soon...(Or later..)", 209, 169, 172, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Calibri")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$AboutSheet = GUICtrlCreateTabItem("About")
$Label3 = GUICtrlCreateLabel("Coming Soon...(Or later..)", 209, 169, 172, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Calibri")
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlCreateTabItem("")
$btnApply = GUICtrlCreateButton("&Apply", 342, 368, 75, 25)
GUICtrlSetOnEvent(-1, "btnApplyClick")
$btnCancel = GUICtrlCreateButton("&Cancel", 422, 368, 75, 25)
GUICtrlSetOnEvent(-1, "btnCancelClick")
$btnHelp = GUICtrlCreateButton("&Help", 504, 368, 75, 25)
GUICtrlSetOnEvent(-1, "btnHelpClick")
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###

; Register message for click event
_Notify_RegMsg()

; Set notification location
_Notify_Locate(0)

; Show notifications
Local $New_Message_Count = 0

ConsoleWrite("--Initializing..." & @CRLF)
$hSTDOUT_Logcat = _ReLaunch_Logcat()
$hSTDOUT_Radio = _ReLaunch_Radio()

_ReduceMemory()

Local $data, $Counter = 0
While True
	If Not ProcessExists($hSTDOUT_Logcat) And $USE_LOGCAT Then $hSTDOUT_Logcat = _ReLaunch_Logcat()
	If Not ProcessExists($hSTDOUT_Radio) And $USE_RADIO Then $hSTDOUT_Radio = _ReLaunch_Radio()

	;Check Logcat
	$data &= StdoutRead($hSTDOUT_Logcat)
	If @error Then Sleep(25)
	For $x = 1 To UBound($aLogcat) - 1
		If StringInStr($data, $aLogcat[$x][1]) Then;Match Found
			_New_Message($aLogcat[$x][1], $aLogcat[$x][0])
		EndIf
	Next
	$data = ""

	;Check Radio
	$data &= StdoutRead($hSTDOUT_Radio)
	If @error Then Sleep(25)
	For $x = 1 To UBound($aRadio) - 1
		If StringInStr($data, $aRadio[$x][1]) Then;Match Found
			_New_Message($aRadio[$x][1], $aRadio[$x][0])
		EndIf
	Next
	$data = ""

	$Counter += 1
	If $Counter > 50 Then
		_ReduceMemory()
		$Counter = 0
	EndIf
	Sleep(300)
WEnd


;;;;;;;;;;;;;;;; GUI Functions ;;;;;;;;;;;;;;;;
#Region GUI Functions
Func ADB_MNC_FormClose()
	GUISetState(@SW_HIDE, $ADB_MNC_Form)
EndFunc   ;==>ADB_MNC_FormClose

Func ADB_MNC_FormMaximize()
	GUISetState(@SW_SHOW, $ADB_MNC_Form)
	WinActivate($ADB_MNC_Form)
EndFunc   ;==>ADB_MNC_FormMaximize

Func ADB_MNC_FormMinimize()

EndFunc   ;==>ADB_MNC_FormMinimize

Func ADB_MNC_FormRestore()

EndFunc   ;==>ADB_MNC_FormRestore

Func btnCancelClick()
	ADB_MNC_FormClose()
EndFunc   ;==>btnCancelClick

Func btnHelpClick()
	MsgBox(64, $PROGRAM_NAME & " - Help", "This button will take you to an online help guide. An offline help guide may come to be if neccessary.")
EndFunc   ;==>btnHelpClick

Func btnApplyClick()
	GUICtrlSetState($btnApply, $GUI_DISABLE)
EndFunc   ;==>btnApplyClick

Func TabGroupControlChange()
	ConsoleWrite("Currently on Tab " & GUICtrlRead($TabGroupControl) & @CRLF)
	Return GUICtrlRead($TabGroupControl)
EndFunc   ;==>TabGroupControlChange
#EndRegion GUI Functions


;;;;;;;;;;;;;;;; Internal Notification Functions ;;;;;;;;;;;;;;;;
#Region Internal Notification Functions
Func _New_Message($sMatch, $Custom_Message = "New Message")
	$New_Message_Count += 1
	TraySetToolTip("Running since: " & $Start_Time & @CRLF & "New Message Counter: " & $New_Message_Count & @CRLF & "Last Message at " & _NowTime())
	_Notify_Set(0, Default, Default, "Courier New", False, 250)
	_Notify_Show(_Get_Notification_Icon($sMatch), "", $Custom_Message, 20)
EndFunc   ;==>_New_Message

Func _Get_Notification_Icon($sMatch)
	$Icon = @ScriptDir & "\Notify.ico";Set Default
	For $x = 1 To UBound($aIcon) - 1
		If $aIcon[$x][1] == $sMatch Then Return $aIcon[$x][0];Just return icon even if blank or invalid (which will just show without icon)
	Next
	Return $Icon;No match found, return default
EndFunc   ;==>_Get_Notification_Icon


Func _ReLaunch_Logcat()
	ConsoleWrite("--Relaunching Logcat Verbose...")
	If Not FileExists($INI_SETTINGS_FILE) Then _CreateDefaultSettings()
	$aLogcat = IniReadSection($INI_SETTINGS_FILE, "Logcat")
	If UBound($aLogcat) <= 1 Then;Check number of options
		$USE_LOGCAT = False;There are no options for Logcat, disable Logcat check
		ConsoleWrite("No options found for Logcat...No longer monitoring Logcat..." & @CRLF)
		Return False
	EndIf
	$hPID = Run(@ComSpec & " /c " & 'adb logcat -v long *:V', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	ConsoleWrite("[" & $hPID & "]" & @CRLF)
	Return $hPID
EndFunc   ;==>_ReLaunch_Logcat

Func _ReLaunch_Radio()
	ConsoleWrite("--Relaunching Logcat Radio...")
	If Not FileExists($INI_SETTINGS_FILE) Then _CreateDefaultSettings()
	$aRadio = IniReadSection($INI_SETTINGS_FILE, "Radio")
	If UBound($aRadio) <= 1 Then;Check number of options
		$USE_RADIO = False;There are no options for Radio, disable radio check
		ConsoleWrite("No options found for Radio...No longer monitoring Logcat Radio..." & @CRLF)
		Return False
	EndIf
	$hPID = Run(@ComSpec & " /c " & 'adb logcat -b radio', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	ConsoleWrite("[" & $hPID & "]" & @CRLF)
	Return $hPID
EndFunc   ;==>_ReLaunch_Radio

Func _CreateDefaultSettings()
	ConsoleWrite("Creating default settings in [" & $INI_SETTINGS_FILE & "]..." & @CRLF)

	FileWrite($INI_SETTINGS_FILE, "#########################################")
	; Write the sample instruction string
;~ 	IniWrite($INI_SETTINGS_FILE, "Icon Display", "Icon file name (Must be local to executable directory) (PNG|ICO)", "Matching text to display icon for")
;~ 	FileWrite($INI_SETTINGS_FILE, @CRLF)

	; Write the string to the section labeled 'Icon'.
	IniWrite($INI_SETTINGS_FILE, "Icon", "Notify.ico", "< SMS_ACKNOWLEDGE")
	FileWrite($INI_SETTINGS_FILE, @CRLF)

	FileWrite($INI_SETTINGS_FILE, "#########################################")

	; Write the sample instruction string
;~ 	IniWrite($INI_SETTINGS_FILE, "Log Type", "Text To Display", "Text to match in log")
;~ 	FileWrite($INI_SETTINGS_FILE, @CRLF)

	; Write the string to the section labeled 'Radio'.
	IniWrite($INI_SETTINGS_FILE,"Radio","New SMS Message","< SMS_ACKNOWLEDGE")
	FileWrite($INI_SETTINGS_FILE, @CRLF)

	; Write the string to the section labeled 'Logcat'.
	IniWrite($INI_SETTINGS_FILE, "Logcat", "New TextPlus Message","Displayed com.gogii.textplus")
	FileWrite($INI_SETTINGS_FILE, @CRLF)

	FileWrite($INI_SETTINGS_FILE,"#########################################")
EndFunc   ;==>_CreateDefaultSettings

Func _Array2DAppend(ByRef $aArray, ByRef $aArray2)
	;;;
	;Appends two 2D arrays
	;Appends Content of Array2 to Array
	;Size does not matter, will adapt to larger array width
	If UBound($aArray, 2) < UBound($aArray2, 2) Then
		;$aArray2 is Boss (Wider)
		ReDim $aArray[UBound($aArray, 1)][UBound($aArray2, 2)];Resize First array to "width" of Array2
	EndIf

	For $x = 0 To UBound($aArray2, 1) - 1;Loop through Array2 length
		ReDim $aArray[UBound($aArray, 1) + 1][UBound($aArray, 2)];Add Row to Array
		For $y = 0 To UBound($aArray2, 2) - 1;Add column data
			$aArray[UBound($aArray, 1) - 1][$y] = $aArray2[$x][$y]
		Next
	Next
EndFunc   ;==>_Array2DAppend

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
	ConsoleWrite("Shutting Down..." & @CRLF)
	TraySetToolTip("Shutting Down...")
	StdioClose($hSTDOUT_Logcat)
	StdioClose($hSTDOUT_Radio)
	If $USE_LOGCAT Then Run("TaskKill /PID " & $hSTDOUT_Logcat, @ScriptDir, @SW_HIDE)
	If $USE_RADIO Then Run("TaskKill /PID " & $hSTDOUT_Radio, @ScriptDir, @SW_HIDE)
	;Note: Currently, it will leave the adb-server running just in case user is using it in a different process
	;		Don't be obnoxious and close out whatever the user is running through adb!
	;		Besides, adb server's footprint is very small anyway...
	Exit
EndFunc   ;==>Terminate
#EndRegion Internal Notification Functions
