#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIListViewEx.au3"

#include <Array.au3> ; Just for display in example

Opt("GUICloseOnESC", 0)

Global $iCount_Left = 20, $iCount_Right = 20, $vData, $sMsg, $aLV_List_Left, $aLV_List_Right, $aRet, $iEditMode = 0

; Create GUI
$hGUI = GUICreate("LVEx Example 1", 640, 510)

; Create Left ListView
GUICtrlCreateLabel("Native ListView" & @CRLF & "Multiple selection - no count - sort && editable (0 && 2)", 10, 5, 300, 30)

$cListView_Left = GUICtrlCreateListView("Tom|James|Harry", 10, 40, 300, 300, $LVS_SHOWSELALWAYS)
_GUICtrlListView_SetExtendedListViewStyle($cListView_Left, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))
_GUICtrlListView_SetColumnWidth($cListView_Left, 0, 93)
_GUICtrlListView_SetColumnWidth($cListView_Left, 1, 93)
_GUICtrlListView_SetColumnWidth($cListView_Left, 2, 93)
; Set font
GUICtrlSetFont($cListView_Left, 12, Default, Default, "Courier New") ; Note edit control will use same font

; Create array and fill Left listview
Global $aLV_List_Left[$iCount_Left]
For $i = 0 To UBound($aLV_List_Left) - 1
	If Mod($i, 5) Then
		$aLV_List_Left[$i] = "Tom " & $i & "|James " & $i & "|Harry " & $i
	Else
		$aLV_List_Left[$i] = "Tom " & $i & "||Harry " & $i
	EndIf
	GUICtrlCreateListViewItem($aLV_List_Left[$i], $cListView_Left)
Next

; Initiate LVEx - use filling array - no count parameter - default insert mark colour (black) - drag image - sort & editable - only cols 0 & 2 (plus headers) editable
$iLV_Left_Index = _GUIListViewEx_Init($cListView_Left, $aLV_List_Left, 0, 0, True, 1 + 2 + 8, "0;2")

; Create Right ListView
GUICtrlCreateLabel("UDF ListView" & @CRLF & "Single sel - count element - editable (all)", 430, 5, 300, 30)

$hListView_Right = _GUICtrlListView_Create($hGUI, "", 430, 40, 200, 300, BitOR($LVS_DEFAULT, $WS_BORDER))
_GUICtrlListView_SetExtendedListViewStyle($hListView_Right, $LVS_EX_FULLROWSELECT)
_GUICtrlListView_AddColumn($hListView_Right, "Peter", 83)
_GUICtrlListView_AddColumn($hListView_Right, "Paul", 83)
_GUICtrlListView_AddColumn($hListView_Right, "Mary", 83)

_GUICtrlListView_SetTextBkColor($hListView_Right, 0xDDFFDD)

; Fill Right ListView
For $i = 1 To $iCount_Right
	_GUICtrlListView_AddItem($hListView_Right, "Peter " & $i - 1)
	If Mod($i, 4) Then
		_GUICtrlListView_AddSubItem($hListView_Right, $i - 1, "Paul " & $i - 1, 1)
	EndIf
	_GUICtrlListView_AddSubItem($hListView_Right, $i - 1, "Mary " & $i - 1, 2)
Next

; Read array from Right  ListView
Global $aLV_List_Right = _GUIListViewEx_ReadToArray($hListView_Right, 1)
; The array as read from Right ListView and used subsequently
;_ArrayDisplay($aLV_List_Right, "Read from Right ListView")

; Initiate LVEx - use read content as array - count parameter set - red insert mark - drag image - editable - all cols editable by default (plus headers)
$iLV_Right_Index = _GUIListViewEx_Init($hListView_Right, $aLV_List_Right, 1, 0xFF0000, True, 2 + 4 + 8 + 16)

; Create Edit Mode Combos
GUICtrlCreateLabel("Edit Modes", 330, 50, 60, 20)
GUICtrlCreateLabel("0" & @CRLF & "1" & @CRLF & "2" & @CRLF & "3", 330, 70, 10, 80)
GUICtrlCreateLabel(":  Single Edit" & @CRLF & ":  Exit Edge" & @CRLF & ":  Stay Edge" & @CRLF & ":  Loop Edge", 340, 70, 65, 80)
GUICtrlCreateLabel("Row Mode", 330, 140, 60, 20)
$cCombo_Row = GUICtrlCreateCombo("", 330, 160, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Row, "0|1|2|3", 0)
GUICtrlCreateLabel("Col Mode", 330, 200, 60, 20)
$cCombo_Col = GUICtrlCreateCombo("", 330, 220, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Col, "0|1|2|3", 0)
GUICtrlCreateLabel("ESC Mode", 330, 260, 75, 20)
$cCombo_Reset = GUICtrlCreateCombo("", 330, 280, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Reset, "Exit Edit|Reset All", "Exit Edit")

; Create buttons
$cInsert_Button = GUICtrlCreateButton("Insert", 10, 350, 200, 30)
$cDelete_Button = GUICtrlCreateButton("Delete", 10, 390, 200, 30)
$cUp_Button = GUICtrlCreateButton("Move Up", 220, 350, 200, 30)
$cDown_Button = GUICtrlCreateButton("Move Down", 220, 390, 200, 30)
$cEdit_Left_Button = GUICtrlCreateButton("Edit Left 1,1", 10, 430, 200, 30)
$cEdit_Right_Button = GUICtrlCreateButton("Edit Right 5,0", 220, 430, 200, 30)
$cHeader_Left_Button = GUICtrlCreateButton("Edit Left Header 1", 10, 470, 200, 30)
$cHeader_Right_Button = GUICtrlCreateButton("Edit Right Header 0", 220, 470, 200, 30)
$cDisplay_Left_Button = GUICtrlCreateButton("Show Left", 430, 350, 100, 30)
$cDisplay_Right_Button = GUICtrlCreateButton("Show Right", 530, 350, 100, 30)
$cExit_Button = GUICtrlCreateButton("Exit", 430, 390, 200, 110)

GUISetState()

; Register for sorting, dragging and editing
_GUIListViewEx_MsgRegister()

; Set the left ListView as active
_GUIListViewEx_SetActive(1)

Switch _GUIListViewEx_GetActive()
	Case 0
		$sMsg = "No ListView is active"
	Case 1
		$sMsg = "The LEFT ListView is active" & @CRLF & "<--------------------------"
	Case 2
		$sMsg = "The RIGHT ListView is active" & @CRLF & "---------------------------->"
EndSwitch
;MsgBox(0, "Active ListView", $sMsg)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $cExit_Button
			Exit

		Case $cInsert_Button
			; Prepare data  for insertion
			Switch $aGLVEx_Data[0][1]
				Case 1
					; String format with multi-column native ListView
					$vData = "Tom " & $iCount_Left & "|James " & $iCount_Left & "|Harry " & $iCount_Left
					$iCount_Left += 1
					_GUIListViewEx_Insert($vData)
				Case 2
					; Array format with multi-column UDF ListView
					Global $vData[3] = ["Peter " & $iCount_Right, "Paul " & $iCount_Right, "Mary " & $iCount_Right]
					$iCount_Right += 1
					_GUIListViewEx_Insert($vData)
			EndSwitch

		Case $cDelete_Button
			_GUIListViewEx_Delete()

		Case $cUp_Button
			_GUIListViewEx_Up()

		Case $cDown_Button
			_GUIListViewEx_Down()

		Case $cDisplay_Left_Button

			$aLV_List_Left = _GUIListViewEx_ReturnArray($iLV_Left_Index)
			If Not @error Then
				_ArrayDisplay($aLV_List_Left, "Returned Left")
			Else
				MsgBox(0, "Left", "Empty Array")
			EndIf
			$aLV_List_Left = _GUIListViewEx_ReturnArray($iLV_Left_Index, 1)
			If Not @error Then
				_ArrayDisplay($aLV_List_Left, "Returned Left Checkboxes")
			Else
				MsgBox(0, "Left", "Empty Check Array")
			EndIf

		Case $cDisplay_Right_Button

			$aLV_List_Right = _GUIListViewEx_ReturnArray($iLV_Right_Index)
			If Not @error Then
				_ArrayDisplay($aLV_List_Right, "Returned Right")
			Else
				MsgBox(0, "Right", "Empty Array")
			EndIf

		Case $cEdit_Left_Button
			; Note abilty to edit columns which cannot be edited via doubleclick
			$aRet = _GUIListViewEx_EditItem($iLV_Left_Index, 1, 1, $iEditMode) ; Use combos to change EditMode
			; Check array exists
			If IsArray($aRet) Then
				; Uncomment to see returned array
				;_ArrayDisplay($aRet, @error)
			EndIf

		Case $cEdit_Right_Button
			$aHdr_Ret = _GUIListViewEx_EditItem($iLV_Right_Index, 5, 0, $iEditMode) ; Use combos to change EditMode
			$aRet = _GUIListViewEx_EditItem($iLV_Left_Index, 1, 1, $iEditMode) ; Use combos to change EditMode
			; Check array exists
			If IsArray($aRet) Then
				; Uncomment to see returned array
				;_ArrayDisplay($aRet, @error)
			EndIf

		Case $cHeader_Left_Button
			; Note abilty to edit headers which cannot be edited via Ctrl-click
			$aHdr_Ret = _GUIListViewEx_EditHeader($iLV_Left_Index, 1)
			; Uncomment to see returned array
			;_ArrayDisplay($aHdr_Ret, @error)

		Case $cHeader_Right_Button
			$aHdr_Ret = _GUIListViewEx_EditHeader($iLV_Right_Index, 0)
			; Uncomment to see returned array
			;_ArrayDisplay($aHdr_Ret, @error)

		Case $cCombo_Row
			Switch GUICtrlRead($cCombo_Row)
				Case 0
					; Both must be set to 0
					GUICtrlSetData($cCombo_Col, 0)
				Case Else
					; Neither must be set to 0 - so match selections
					If GUICtrlRead($cCombo_Col) = 0 Then
						GUICtrlSetData($cCombo_Col, GUICtrlRead($cCombo_Row))
					EndIf
			EndSwitch
			; Set required edit mode
			$iEditMode = Number(GUICtrlRead($cCombo_Row) & GUICtrlRead($cCombo_Col))

		Case $cCombo_Col
			Switch GUICtrlRead($cCombo_Col)
				Case 0
					GUICtrlSetData($cCombo_Row, 0)
				Case Else
					If GUICtrlRead($cCombo_Row) = 0 Then
						GUICtrlSetData($cCombo_Row, GUICtrlRead($cCombo_Col))
					EndIf
			EndSwitch
			$iEditMode = Number(GUICtrlRead($cCombo_Row) & GUICtrlRead($cCombo_Col))

		Case $cCombo_Reset
			; Toggle edit mode value to switch ESC modes
			$iEditMode *= -1

	EndSwitch

	$aRet = _GUIListViewEx_EditOnClick($iEditMode) ; Use combos to change EditMode
	; Array only returned AFTER EditOnClick process - so check array exists
	If IsArray($aRet) Then
		; Uncomment to see returned array
		;_ArrayDisplay($aRet, @error)
	EndIf

WEnd
