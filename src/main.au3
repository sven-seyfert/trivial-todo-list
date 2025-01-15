#pragma compile(FileVersion, 0.2.0)
#pragma compile(LegalCopyright, © Sven Seyfert (SOLVE-SMART))
#pragma compile(ProductVersion, 0.2.0 - 2025-01-15)

#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Outfile_x64=..\build\trivial-todo-list.exe
#AutoIt3Wrapper_Run_Au3Stripper=y
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=y
#Au3Stripper_Parameters=/sf /sv /mo /rm /rsln

#include-once
#include <GuiListView.au3>
#include ".\utils\app-update-handler.au3"

Global $mGui[]

_Main()

Func _Main()
    If @Compiled Then
        _TryAppUpdate()
    EndIf

    Local Const $sFile       = '..\data\todos.txt'
    Local Const $sAppVersion = _GetAppVersion()

    _CreateGui($sAppVersion)
    _LoadTodos($sFile)

    GUISetState(@SW_SHOW, $mGui.Handle)

    _HandleGuiEvents($sFile)
EndFunc

Func _GetAppVersion()
    Local Const $sFullAppVersion = FileGetVersion(@ScriptName)
    Return StringRegExp($sFullAppVersion, '(\d+\.\d+\.\d+)', 1)[0]
EndFunc

Func _CreateGui($sAppVersion)
    Local Const $vSunkenEdgeFlag = 0x00000200

    $mGui.Handle = GUICreate(StringFormat('todo-list (v%s)', $sAppVersion), 400, 400)
                   GUISetFont(12)

    $mGui.Todo   = GUICtrlCreateInput('', 15, 15, 250, 30) ; 400 -15 -15 -50 -50 -15
    $mGui.Add    = GUICtrlCreateButton('➕', 280, 15, 50)
    $mGui.Remove = GUICtrlCreateButton('➖', 335, 15, 50)
    $mGui.List   = _GUICtrlListView_Create($mGui.Handle, '0 TODOs', 15, 60, 370, 280, $LVS_REPORT, $vSunkenEdgeFlag)
                   _GUICtrlListView_SetColumnWidth($mGui.List, 0, 366)
                   _GUICtrlListView_SetExtendedListViewStyle($mGui.List, $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
    $mGui.Close  = GUICtrlCreateButton('Close', 15, 355, 370)
EndFunc

Func _LoadTodos($sFile)
    If Not FileExists($sFile) Then
        Return
    EndIf

    Local Const $aTODOs = FileReadToArray($sFile)

    _SetItemCount(Ubound($aTODOs))

    For $sTODO In $aTODOs
        _GUICtrlListView_AddItem($mGui.List, $sTODO)
    Next
EndFunc

Func _HandleGuiEvents($sFile)
    Local Const $iGuiCloseEvent = -3

    While True
        Switch GUIGetMsg()
            Case $iGuiCloseEvent, $mGui.Close
                _SaveTodos($sFile)
                GUIDelete($mGui.Handle)
                ExitLoop

            Case $mGui.Add
                _AddTodo()

            Case $mGui.Remove
                _RemoveTodo()
        EndSwitch
    WEnd

    Exit
EndFunc

Func _AddTodo()
    Local Const $sTODO = GUICtrlRead($mGui.Todo)
    If $sTODO == '' Or StringRegExp($sTODO, '^(\s+)$') Then
        GUICtrlSetData($mGui.Todo, '')
        Return
    EndIf

    _SetItemCount(1)

    _GUICtrlListView_AddItem($mGui.List, $sTODO)
    GUICtrlSetData($mGui.Todo, '')
EndFunc

Func _SetItemCount($i)
    Local Const $iItemCount = _GUICtrlListView_GetItemCount($mGui.List) + $i
    _GUICtrlListView_SetColumn($mGui.List, 0, $iItemCount & ' TODOs')
EndFunc

Func _RemoveTodo()
    Local Const $aItem = _GUICtrlListView_GetSelectedIndices($mGui.List, True)
    If $aItem[0] == 0 Then
        Return
    EndIf

    _SetItemCount(-1)

    _GUICtrlListView_DeleteItem($mGui.List, $aItem[1])
EndFunc

Func _SaveTodos($sFile)
    FileDelete($sFile)

    Local Const $iItemCount = _GUICtrlListView_GetItemCount($mGui.List) - 1
    Local $sTODO

    For $i = 0 To $iItemCount
        $sTODO = _GUICtrlListView_GetItemTextString($mGui.List, $i)
        _AppendToFile($sFile, $sTODO & @CRLF)
    Next
EndFunc

Func _AppendToFile($sFile, $sText)
    Local Const $iUtf8WithoutBomAndAppendCreationMode = 256 + 1 + 8

    Local $hFile = FileOpen($sFile, $iUtf8WithoutBomAndAppendCreationMode)
    FileWrite($hFile, $sText)
    FileClose($hFile)
EndFunc
