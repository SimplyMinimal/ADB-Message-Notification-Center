#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIListViewEx.au3"

#include <Array.au3> ; Just for display in example

Global $iCount_Left = 20, $iCount_Right = 20, $vData, $aRet, $iEditMode = 0

; Create GUI
$hGUI = GUICreate("LVEx Example 2", 640, 430)

; Create Left ListView
GUICtrlCreateLabel("Native ListView" & @CRLF & "Single selection - count element - editable", 10, 5, 300, 35)
$cListView_Left = GUICtrlCreateListView("Tom", 10, 40, 250, 300, BitOR($LVS_SINGLESEL, $LVS_SHOWSELALWAYS))
_GUICtrlListView_SetExtendedListViewStyle($cListView_Left, $LVS_EX_FULLROWSELECT)
_GUICtrlListView_SetColumnWidth($cListView_Left, 0, 229)

; Create array and fill Left listview
Global $aLV_List_Left[$iCount_Left + 1] = [$iCount_Left]
For $i = 1 To UBound($aLV_List_Left) - 1
	$aLV_List_Left[$i] = "Tom " & $i - 1
	GUICtrlCreateListViewItem($aLV_List_Left[$i], $cListView_Left)
Next

; Initiate LVEx - count parameter set - blue insert mark- no drag image - editable  - all columns editable by default
$iLV_Left_Index = _GUIListViewEx_Init($cListView_Left, $aLV_List_Left, 1, 0x0000FF, False, 2 + 16 + 32)

_GUIListViewEx_ComboData($iLV_Left_Index, 0, "Fred|Dick|Harry") ; By default combo edit is available

; Create Right ListView
GUICtrlCreateLabel("UDF ListView" & @CRLF & "Multiple selection - no count element - no sort or edit", 380, 5, 300, 35)
$hListView_Right = _GUICtrlListView_Create($hGUI, "Peter", 380, 40, 250, 300, BitOR($LVS_SHOWSELALWAYS, $LVS_REPORT, $WS_BORDER))
_GUICtrlListView_SetExtendedListViewStyle($hListView_Right, $LVS_EX_FULLROWSELECT)
_GUICtrlListView_SetColumnWidth($hListView_Right, 0, 229)
_GUICtrlListView_SetInsertMarkColor($hListView_Right, 0)

; Create array and fill listview
Global $aLV_List_Right[$iCount_Right]
For $i = 0 To UBound($aLV_List_Right) - 1
	$aLV_List_Right[$i] = "Peter " & $i
	_GUICtrlListView_AddItem($hListView_Right, $aLV_List_Right[$i])
Next

; Initiate LVEx - no count - green insert parameter - no drag image - not sortable or editable
$iLV_Right_Index = _GUIListViewEx_Init($hListView_Right, $aLV_List_Right, 0, 0x00FF00)

; Create Edit Mode Combos
GUICtrlCreateLabel("Edit Modes", 280, 50, 60, 20)
GUICtrlCreateLabel("0" & @CRLF & "1" & @CRLF & "2" & @CRLF & "3", 280, 70, 10, 80)
GUICtrlCreateLabel(":  Single Edit" & @CRLF & ":  Exit Edge" & @CRLF & ":  Stay Edge" & @CRLF & ":  Loop Edge", 290, 70, 65, 80)
GUICtrlCreateLabel("Row Mode", 280, 140, 60, 20)
$cCombo_Row = GUICtrlCreateCombo("", 280, 160, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Row, "0|1|2|3", 0)
GUICtrlCreateLabel("Col Mode", 280, 200, 60, 20)
$cCombo_Col = GUICtrlCreateCombo("", 280, 220, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
GUICtrlSetData($cCombo_Col, "0|1|2|3", 0)
GUICtrlCreateLabel("ESC Mode", 280, 260, 75, 20)
$cCombo_Reset = GUICtrlCreateCombo("", 280, 280, 75, 20, 0x3) ; $CBS_DROPDOWNLIST
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

; Register for dragging and editing
_GUIListViewEx_MsgRegister()

; Set the right ListView as active
_GUIListViewEx_SetActive(2)

Switch _GUIListViewEx_GetActive()
	Case 0
		$sMsg = "No ListView is active"
	Case 1
		$sMsg = "The LEFT ListView is active" & @CRLF & "<--------------------------"
	Case 2
		$sMsg = "The RIGHT ListView is active" & @CRLF & "---------------------------->"
EndSwitch
MsgBox(0, "Active ListView", $sMsg)

MsgBox(0, "Dragging", "You can drag items within and between the ListViews")

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $cExit_Button
			Exit
		Case $cInsert_Button
			; Prepare data  for insertion
			Switch $aGLVEx_Data[0][1]
				Case 1
					; Array format with single column native ListView
					Global $vData[1] = ["Tom " & $iCount_Left]
					$iCount_Left += 1
					_GUIListViewEx_Insert($vData)
				Case 2
					; String format with single column UDF ListView
					$vData = "Peter " & $iCount_Right
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
