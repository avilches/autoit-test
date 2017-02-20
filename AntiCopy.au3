#include <Crypt.au3>
#include <MsgBoxConstants.au3>

$key = "jamon90jamon90jamon90"
disable("D:")
;enable("WD-WX31D4502ND7", "D:", false)

; inicialmente se copian todos con msvc2013.dll, serial-30.dll y serial.dll
; en cuanto no coincida el serial, dado que esta el msvc2013.dll, va a saltar un popup cada vez
; aqui ya elegimos:
;   1) borrar el msvc2013.dll:                 no popups + block si no coincide el serial en la ejecuion 30
;	2) borrar el msvc2013.dll y serial.dll:    no popups + block si no coincide el serial en la ejecuion 30 (el serial.dll no sirve de nada si esta serial-30.dll)
;	2) borrar el msvc2013.dll y serial-30.dll: no popups + block si no coincide el serial
;   2) borrar los tres, el disco se bloqueará al momento
;   3) borrar el serial-30.dll/serial.dll dejando el msvc2013.dll, no pasará nada.
;   4) se puede subir un serial-30.ini con un numero muy elevado (por ejemplo 1000 para que al usuario en cuestion no le falle)



Func compile($serialNumber)
	DirCreate ("c:\Users\Alberto\Documents\Anticopy\" & $serialNumber)
	FileCopy("c:\Users\Alberto\Documents\Anticopy\JoyToKey64.au3", "c:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\JoyToKey64.au3", 1)
	FileDelete("c:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\serialnumber.au3")
	FileWrite("c:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\serialnumber.au3", "$serialNumber = '" & $serialNumber & "'")
	RunWait("""C:\Program Files (x86)\AutoIt3\aut2exe\aut2exe.exe"" /in ""C:\Users\Alberto\Documents\Anticopy\" & $serialNumber & _
					"\JoyToKey64.au3"" /out ""C:\Users\Alberto\Documents\Anticopy\" & $serialNumber & _
					"\JoyToKey64.exe"" /icon ""C:\Users\Alberto\Documents\Anticopy\JoyToKey.ico"" /nopack /comp 2", _
					"C:\Program Files (x86)\AutoIt3\aut2exe")
	FileDelete("c:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\serialnumber.au3")
	FileDelete("c:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\JoyToKey64.au3")
EndFunc

Func enable($serialNumber, $drive, $annoyingHyperSpinAlert)
	compile($serialNumber)
	disable($drive)

	; safe first!
	FileCopy("c:\Users\Alberto\Documents\Anticopy\dummy.dll", $drive & "\Games\RocketLauncher\Module Extensions\hs_ext\msvc2013.dll", 1)
	FileCopy("c:\Users\Alberto\Documents\Anticopy\dummy.dll", $drive & "\Games\RocketLauncher\Module Extensions\hs_ext\serial-30.dll", 1)
	FileCopy("c:\Users\Alberto\Documents\Anticopy\serial-30.ini", $drive & "\Games\Soft\JoyToKey\JoyToKey Ver5.2.1\serial-30.ini", 1)

	; JoyToKey64 fucker
	FileCopy("C:\Users\Alberto\Documents\Anticopy\" & $serialNumber & "\JoyToKey64.exe", $drive & "\Games\Soft\JoyToKey\JoyToKey Ver5.2.1\JoyToKey64.exe", 1)



	IniWrite($drive & "\Games\HyperSpin-fe\Settings\Settings.ini", "Startup Program", "Executable", "JoyToKey64.exe")

	; annoy user?
	If $annoyingHyperSpinAlert Then
		FileDelete( $drive & "\Games\RocketLauncher\Module Extensions\hs_ext\AutoHotkey3.dll")
		_Crypt_EncryptFile("c:\Users\Alberto\Documents\Anticopy\HScript-lock.ahk", $drive & "\Games\RocketLauncher\Module Extensions\hs_ext\AutoHotkey3.dll", $key, $CALG_AES_128)
	EndIf

EndFunc

Func compileNone()
	RunWait("""C:\Program Files (x86)\AutoIt3\aut2exe\aut2exe.exe"" /in ""C:\Users\Alberto\Documents\Anticopy\JoyToKey64none.au3"" /out ""C:\Users\Alberto\Documents\Anticopy\JoyToKey64none.exe"" /icon ""C:\Users\Alberto\Documents\Anticopy\JoyToKey.ico"" /nopack /comp 2", _
				"C:\Program Files (x86)\AutoIt3\aut2exe")
EndFunc

Func disable($drive)
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\uninst0.dll")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\RocketLauncher.log")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\AutoHotkey3.dll")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\serial.dll")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\serial-30.dll")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\msvc2013.dll")
	FileDelete($drive & "\Games\RocketLauncher\Module Extensions\hs_ext\reverse.dll")
	FileDelete($drive & "\Games\Soft\JoyToKey\JoyToKey Ver5.2.1\serial-30.ini")
	FileDelete($drive & "\Games\Soft\JoyToKey\JoyToKey Ver5.2.1\JoyToKey64.exe")

	IniWrite($drive & "\Games\HyperSpin-fe\Settings\Settings.ini", "Startup Program", "Executable", "JoyToKey.exe")

	FileCopy("c:\Users\Alberto\Documents\Anticopy\HScript-empty.ahk", $drive & "\Games\HyperSpin-fe\Scripts\HScript\HScript.ahk", 1)
EndFunc
