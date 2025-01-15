;~ get app version online
Func _TryAppUpdate()
    Local Const $sApp        = StringReplace(@ScriptName, '.exe', '')
    Local Const $sAppVersion = _GetAppVersionOnline($sApp)
    If Not @error Then
        If _IsAppVersionNewer($sAppVersion) Then
            Local Const $sNewApp = _DownloadApp(StringReplace(@ScriptName, '.exe', ''))
            If Not @error Then
                MsgBox(64, 'Update to v' & $sAppVersion, 'Update available and being applied.', 5)
                _UpdateApp($sNewApp)
            EndIf
        EndIf
    EndIf
EndFunc

Func _GetAppVersionOnline($sApp)
    Local Const $sFileName = 'versions.ini'
    Local Const $sUrl      = StringFormat('https://raw.githubusercontent.com/sven-seyfert/app-versions/refs/heads/main/%s', $sFileName)
    Local Const $sFile     = StringFormat('%s\%s', @TempDir, $sFileName)

    FileDelete($sFile)

    Local Const $iForceReloadIgnoreSSLError = 1 + 2
    Local Const $iByteSize = InetGet($sUrl, $sFile, $iForceReloadIgnoreSSLError)
    If $iByteSize == 0 Then
        Return SetError(1, -1, 'InetGet failed.')
    EndIf

    Local Const $sAppVersion = IniRead($sFile, 'app-versions', $sApp, '-')
    If $sAppVersion == '-' Or $sAppVersion == '' Then
        Return SetError(1, -1, 'No app version found.')
    EndIf

    Return $sAppVersion
EndFunc

;~ check is app version newer
Func _IsAppVersionNewer($sVersion)
    Local Const $aCurrentVersion  = StringSplit(FileGetVersion(@ScriptName), '.')
    Local Const $aReceivedVersion = StringSplit($sVersion, '.')

    For $i = 1 To 3
        Local $iCurrentVersionPart  = Number($aCurrentVersion[$i])
        Local $iReceivedVersionPart = Number($aReceivedVersion[$i])

        If $iCurrentVersionPart < $iReceivedVersionPart Then
            Return True
        ElseIf $iCurrentVersionPart > $iReceivedVersionPart Then
            Return False
        EndIf
    Next

    Return False
EndFunc

;~ if yes, download app
Func _DownloadApp($sApp)
    Local Const $sUrl  = StringFormat('https://github.com/sven-seyfert/trivial-todo-list/raw/refs/heads/main/build/%s.exe', $sApp)
    Local Const $sFile = StringFormat('%s-update.exe', $sApp)

    Local Const $iForceReloadIgnoreSSLError = 1 + 2
    Local Const $iByteSize = InetGet($sUrl, $sFile, $iForceReloadIgnoreSSLError)
    If $iByteSize == 0 Then
        Return SetError(1, -1, 'InetGet failed.')
    EndIf

    Return $sFile
EndFunc

;~ then update app
Func _UpdateApp($sUpdateExecutable)
    If Not @Compiled Then
        Return
    EndIf

    Local Const $sProgramFilePath                = @ScriptFullPath
    Local Const $iFastNotCaseSensitiveMode       = 2
    Local Const $iFirstOccurrenceRightToLeftMode = -1

    Local Const $sSubStringPosition = StringInStr($sProgramFilePath, '\', $iFastNotCaseSensitiveMode, $iFirstOccurrenceRightToLeftMode)
    Local Const $sFileName          = StringTrimLeft($sProgramFilePath, $sSubStringPosition)
    Local Const $sWorkingDir        = StringTrimRight($sProgramFilePath, StringLen($sFileName))

    Local Const $sCommand = StringFormat( _
        ' /C ping localhost -n 2 & del /F "%s" & move "%s" "%s" & start "" "%s"', _
        $sFileName, $sUpdateExecutable, $sFileName, $sFileName)

    Run(@ComSpec & $sCommand, $sWorkingDir, @SW_HIDE)
    Exit ; This Exit here is essential.
EndFunc

;~ error handling


;~ change of trivial-todo-list (new version)
