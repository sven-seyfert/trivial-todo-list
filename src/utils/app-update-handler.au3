Func _TryUpdateApp($mDownloadUrl)
    Local Const $sAppName    = StringReplace(@ScriptName, '.exe', '')
    Local Const $sAppVersion = _GetAppVersionOnline($sAppName, $mDownloadUrl)
    If @error Then
        Return
    EndIf

    If Not _IsAppVersionNewer($sAppVersion) Then
        Return
    EndIf

    Local Const $sUpdatedAppFile = _DownloadApp($sAppName, $mDownloadUrl)
    If @error Then
        Return
    EndIf

    Local Const $iInfoIconTopMostFlag = 64 + 262144
    MsgBox($iInfoIconTopMostFlag, 'Update to v' & $sAppVersion, 'Update available and is now being applied.', 10)

    _UpdateApp($sUpdatedAppFile) ; The program will be exited here.
EndFunc

Func _GetAppVersionOnline($sAppName, $mDownloadUrl)
    Local Const $sFileName = 'versions.ini'
    Local Const $sUrl      = StringFormat('%s/%s', $mDownloadUrl.VersionsIni, $sFileName)
    Local Const $sFile     = StringFormat('%s\%s', @TempDir, $sFileName)

    FileDelete($sFile)

    Local Const $iForceReloadIgnoreSSLErrors = 1 + 2
    Local Const $iByteSize = InetGet($sUrl, $sFile, $iForceReloadIgnoreSSLErrors)
    If $iByteSize == 0 Then
        Return SetError(1, -1, 'InetGet failed.')
    EndIf

    Local Const $sAppVersion = IniRead($sFile, 'app-versions', $sAppName, '-')
    If $sAppVersion == '-' Or $sAppVersion == '' Then
        Return SetError(1, -2, 'No app version found.')
    EndIf

    Return $sAppVersion
EndFunc

Func _IsAppVersionNewer($sVersion) ; Expected version formart is "Major.Minor.Patch".
    Local Const $aCurrentVersion  = StringSplit(FileGetVersion(@ScriptName), '.')
    Local Const $aReceivedVersion = StringSplit($sVersion, '.')
    Local $iCurrentVersionPart, $iReceivedVersionPart

    For $i = 1 To 3
        $iCurrentVersionPart  = Number($aCurrentVersion[$i])
        $iReceivedVersionPart = Number($aReceivedVersion[$i])

        If $iCurrentVersionPart < $iReceivedVersionPart Then
            Return True
        ElseIf $iCurrentVersionPart > $iReceivedVersionPart Then
            Return False
        EndIf
    Next

    Return False
EndFunc

Func _DownloadApp($sAppName, $mDownloadUrl)
    Local Const $sUrl  = StringFormat('%s/%s.exe', $mDownloadUrl.AppExecutable, $sAppName)
    Local Const $sFile = StringFormat('%s-update.exe', $sAppName)

    FileDelete($sFile)

    Local Const $iForceReloadIgnoreSSLErrors = 1 + 2
    Local Const $iByteSize = InetGet($sUrl, $sFile, $iForceReloadIgnoreSSLErrors)
    If $iByteSize == 0 Then
        Return SetError(1, -1, 'InetGet failed.')
    EndIf

    Return $sFile
EndFunc

Func _UpdateApp($sNewExecutable)
    If Not @Compiled Then
        Return
    EndIf

    Local Const $sProgramFilePath                = @ScriptFullPath
    Local Const $iFastNotCaseSensitiveMode       = 2
    Local Const $iFirstOccurrenceRightToLeftMode = -1

    Local Const $sSubStringPosition = StringInStr($sProgramFilePath, '\', $iFastNotCaseSensitiveMode, $iFirstOccurrenceRightToLeftMode)
    Local Const $sCurrentExecutable = StringTrimLeft($sProgramFilePath, $sSubStringPosition)
    Local Const $sWorkingDir        = StringTrimRight($sProgramFilePath, StringLen($sCurrentExecutable))

    Local Const $sCommand = StringFormat( _
        ' /C ping localhost -n 2 & del /F "%s" & move "%s" "%s" & start "" "%s"', _
        $sCurrentExecutable, $sNewExecutable, $sCurrentExecutable, $sCurrentExecutable)

    Run(@ComSpec & $sCommand, $sWorkingDir, @SW_HIDE)
    Exit ; This Exit here is essential.
EndFunc
