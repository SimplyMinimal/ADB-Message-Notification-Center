#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIListViewEx.au3"

Global $iCount_Left = 1, $iCount_Right = 1, $vData, $aRet, $iEditMode = 23

; Create GUI
$hGUI = GUICreate("LVEx Example 3", 640, 430)

; Create Left ListView
GUICtrlCreateLabel("Native ListView" & @CRLF & "Single sel - existing empty rows - count element - editable (all)", 10, 5, 300, 35)
$cListView_Left = GUICtrlCreateListView("Tom|Dick|Harry", 10, 40, 300, 300, $LVS_SINGLESEL)
_GUICtrlListView_SetExtendedListViewStyle($cListView_Left, $LVS_EX_FULLROWSELECT)
_GUICtrlListView_SetColumnWidth($cListView_Left, 0, 93)
_GUICtrlListView_SetColumnWidth($cListView_Left, 1, 93)
_GUICtrlListView_SetColumnWidth($cListView_Left, 2, 93)
_GUICtrlListView_SetInsertMarkColor($cListView_Left, 0)

; Fill ListView with empty items
For $i = 1 To 20
	GUICtrlCreateListViewItem("||", $cListView_Left)
Next
; Create array
$aLV_List_Left = _GUIListViewEx_ReadToArray($cListView_Left, 1) ; Note count element

; Initiate GLVEx - no array passed - count parameter set - default insert mark colour (black) - drag image - editable - all columns editable (default)
$iLV_Left_Index = _GUIListViewEx_Init($cListView_Left, $aLV_List_Left, 1, 0, True, 2)

; Create Right ListView
GUICtrlCreateLabel("UDF ListView" & @CRLF & "Single selection - no count - no sort or edit", 430, 5, 300, 35)
$hListView_Right = _GUICtrlListView_Create($hGUI, "Peter", 430, 40, 200, 300, BitOR($LVS_DEFAULT, $WS_BORDER))
_GUICtrlListView_SetExtendedListViewStyle($hListView_Right, $LVS_EX_FULLROWSELECT)
_GUICtrlListView_SetColumnWidth($hListView_Right, 0, 179)
_GUICtrlListView_SetInsertMarkColor($hListView_Right, 0)

; Initiate GLVEx - no array passed - no count parameter - default insert mark colour (black) - no drag image - not editable or sortable
$iLV_Right_Index = _GUIListViewEx_Init($hListView_Right)

; Create Edit Mode Combos
GUICtrlCreateLabel("Edit Modes", 330, 50, 60, 20)
GUICtrlCreateLabel("0" & @CRLF & "1" & @CRLF & "2" & @CRLF & "3", 330, 70, 10, 80)
GUICtrlCreateLabel(":  Single Edit" & @CRLF & ":  Exit Edge" & @CRLF & ":  Stay Edge" & @CRLF & ":  Loop Edge", 340, 70, 65, 80)
GUICtrlCreateLabel("Row Mode", 330, 140, 60, 20)
$cCombo_Row = GUICtrlCreateCombo("", 330, 160, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Row, "0|1|2|3", 2)
GUICtrlCreateLabel("Col Mode", 330, 200, 60, 20)
$cCombo_Col = GUICtrlCreateCombo("", 330, 220, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Col, "0|1|2|3", 3)
GUICtrlCreateLabel("ESC Mode", 330, 260, 75, 20)
$cCombo_Reset = GUICtrlCreateCombo("", 330, 280, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Reset, "Exit Edit|Reset All", "Exit Edit")

; Create buttons
$cInsert_Button = GUICtrlCreateButton("Insert", 10, 350, 200, 30)
$cDelete_Button = GUICtrlCreateButton("Delete", 10, 390, 200, 30)
$cUp_Button = GUICtrlCreateButton("Move Up", 220, 350, 200, 30)
$cDown_Button = GUICtrlCreateButton("Move Down", 220, 390, 200, 30)
$cDisplay_Left_Button = GUICtrlCreateButton("Show Left", 430, 350, 100, 30)
$cDisplay_Right_Button = GUICtrlCreateButton("Show Right", 530, 350, 100, 30)
$cExit_Button = GUICtrlCreateButton("Exit", 430, 390, 200, 30)

GUISetState()

; Register for editing 7 dragging
_GUIListViewEx_MsgRegister()

; Set neither ListView as active
_GUIListViewEx_SetActive(0)

Switch _GUIListViewEx_GetActive()
	Case 0
		$sMsg = "No ListView is active"
	Case 1
		$sMsg = "The LEFT ListView is active" & @CRLF & "<--------------------------"
	Case 2
		$sMsg = "The RIGHT ListView is active" & @CRLF & "---------------------------->"
EndSwitch
MsgBox(0, "Active ListView", $sMsg)

MsgBox(0, "Info", "The Left ListView has 20 empty rows" & @CRLF & "each of 3 cells which can be edited" & @CRLF & "<--------------------------")

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $cExit_Button
			Exit
		Case $cInsert_Button
			; Prepare data  for insertion
			Switch $aGLVEx_Data[0][1]
				Case 1
					; Array format with multi-column native ListView
					Global $vData[3] = ["Tom " & $iCount_Left, "Dick " & $iCount_Left, "Harry " & $iCount_Left]
					$iCount_Left += 1
					_GUIListViewEx_Insert($vData)
				Case 2
					; Array format with single-column UDF ListView
					Global $vData[1] = ["Peter " & $iCount_Right]
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

		Case $cDisplay_Right_Button
			$aLV_List_Right = _GUIListViewEx_ReturnArray($iLV_Right_Index)
			If Not @error Then
				_ArrayDisplay($aLV_List_Right, "Returned Right")
			Else
				MsgBox(0, "Right", "Empty Array")
			EndIf

		Case $cCombo_Row
			Switch GUICtrlRead($cCombo_Row)
				Case 0
					GUICtrlSetData($cCombo_Col, 0)
				Case Else
					If GUICtrlRead($cCombo_Col) = 0 Then
						GUICtrlSetData($cCombo_Col, GUICtrlRead($cCombo_Row))
					EndIf
			EndSwitch
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

	$aRet = _GUIListViewEx_EditOnClick($iEditMode)
	; Array only returned AFTER EditOnClick process - so check array exists
	If IsArray($aRet) Then
		; Uncomment to see returned array
		;_ArrayDisplay($aRet, @error)
	EndIf


WEnd