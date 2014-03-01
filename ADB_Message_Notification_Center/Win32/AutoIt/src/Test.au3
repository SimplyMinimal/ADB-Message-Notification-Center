#include <Constants.au3>
#include "Array.au3"

Global Const $INI_SETTINGS_FILE = @ScriptDir & "\ADB Message Notification Center.ini"

_ParseSettings()


Func _ParseSettings()
	If Not FileExists($INI_SETTINGS_FILE) Then _CreateDefaultSettings()

	; Read the INI section labelled 'General'. This will return a 2 dimensional array.
	Local $aArray = IniReadSection($INI_SETTINGS_FILE, "Radio")
	_ArrayDisplay($aArray)

	; Check if an error occurred.
	If Not @error Then
		; Enumerate through the array displaying the keys and their respective values.
		For $i = 1 To $aArray[0][0]
			MsgBox($MB_SYSTEMMODAL, "", "Key: " & $aArray[$i][0] & @CRLF & "Value: " & $aArray[$i][1])
		Next
	EndIf
EndFunc   ;==>_ParseSettings

Func _CreateDefaultSettings()
	; Create an INI section structure as a string.
	$SMS_INI = "New SMS Message=< SMS_ACKNOWLEDGE"
	$Logcat_INI = "New TextPlus Message=Displayed com.gogii.textplus"

	; Write the string to the section labelled 'Radio'.
	IniWriteSection($INI_SETTINGS_FILE, "Radio", $SMS_INI)
	FileWrite($INI_SETTINGS_FILE, @CRLF)
	IniWriteSection($INI_SETTINGS_FILE, "Logcat", $Logcat_INI)
EndFunc   ;==>_CreateDefaultSettings
