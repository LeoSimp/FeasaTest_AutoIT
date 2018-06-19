#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Leo

 Script Function:
	UDF for feasala4.dll
	More help with feasala4.dll please refer to DLLreference.pdf in
	C:\Program Files\FEASA Led Analyser\programming\DLL and User Examples\dll
#ce ----------------------------------------------------------------------------
;Version 1.0 relese
; Script Start
#include-once

Global $DLLNAME = 'feasala4.dll'
Global $fPortOpen = False
Global $hDll

;ConsoleWrite("_FeasaSetDllPath: "&_FeasaSetDllPath('feasala4.dll')&@CRLF)
;===============================================================================
;
; Function Name:  _FeasaSetDllPath($sFullPath)
; Description:    Sets full path to the dll so that it can be in any location.
;
; Parameters:     $sFullPath -  Full path to the feasala4.dll
; Returns;  on success 1
;           on error -1 if full path does not exist

;===============================================================================
Func _FeasaSetDllPath($sFullPath)
    If Not FileExists($sFullPath) Then Return -1

    $DLLNAME = $sFullPath
    Return 1

EndFunc

;ConsoleWrite("_ComPortsNum: "&_ComPortsNum()&@CRLF)
;===============================================================================
;
;Function Name: _ComPortsNum()
;Description:	Get COM port numbers
;Parameters:	void
;Returns:		on success - a number
;				on failure - an empty and @error set to 1 if dll could not list any ports
;                                         @error set to 2 if dll not open and couldn't be opened
;Remark:		Do not contains the port which is already connected
;
;===============================================================================
Func _ComPortsNum()
Local $vDllAns
If Not $fPortOpen Then
		;ConsoleWrite($DLLNAME & @LF)
        $hDll = DllOpen($DLLNAME)
        If $hDll = -1 Then
            SetError(2)
            ;$sErr = 'Failed to open feasala4.dll'
            Return ;failed
        EndIf
        $fPortOpen = True
    EndIf

If $fPortOpen Then
	$vDllAns = DllCall($hDll, 'int','LedAnalyser_EnumPorts')
	If @error = 1 Then
		SetError(1)
		Return ''
	Else
		;mgdebugCW($vDllAns[0] & @CRLF)
			Return $vDllAns[0]
	EndIf
    Else
        SetError(1)
        Return ''
    EndIf
EndFunc

;ConsoleWrite("_FeasaConneted: "&_FeasaConneted("024A","57600")&@CRLF)
;===============================================================================
;
;Function Name: _FeasaConneted($SerialNumber,$Baudrate)
;Description:	Returns the port number where the LED Analyser is connected to or -1 if it was not found.
;Parameters:	每 $SerialNumber: string specifying the serial number of the LED Analyser to find.
;				每 $Baudrate: string specifying the baudrate used by the LED Analyser: 9600, 19200, 38400,
;				57600, 115200, 460800, 921600. You can specify the word ※AUTO§ to autodetect the
;				baudrate, but this method is slower.
;Returns:		on success - a port number
;				on failure - an empty and @error set to DllCall error if it was not found.
;										  @error set to 1 if dll not open and couldn't be opened
;Remark:		It's not functional when the port is already connected
;
;===============================================================================
Func _FeasaConneted($SerialNumber,$Baudrate)
	Local $vDllAns,$sErr
    If Not $fPortOpen Then
        SetError(1)
        Return
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_IsConnected','str',$SerialNumber,'str',$Baudrate);reply is port number eg 8
	If @error <> 0 Then
        SetError(@error)
        Return
    Else
		If $vDllAns[0] < 0 Then
			SetError($vDllAns[0])
			Switch $vDllAns[0]
				Case -1
					$sErr = 'not found the connected port'
			EndSwitch
			ConsoleWrite($sErr&@CRLF)
			Return 0
		Else
			Return $vDllAns[0]
		EndIf
    EndIf
EndFunc

;ConsoleWrite("_COMOpen: "&_COMOpen(3,"57600")&@CRLF)
;===============================================================================
;
;Function Name: _COMOpen($CommPort,$Baudrate)
;Description:	This function returns 1 if the port has been successfully opened, 0 on error. Once the port is opened,
;				it stays in locked status, which means that can only be used by the caller application. It can not be
;				used by other software until you close it.
;Parameters:	每 $CommPort: port number to be opened (COMx).
;				每 $Baudrate: string specifying the baudrate used by the LED Analyser: 9600, 19200, 38400,
;				57600, 115200, 460800, 921600. You can specify the word ※AUTO§ to autodetect the
;				baudrate, but this method is slower.
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMOpen($CommPort,$Baudrate)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_Open','int',$CommPort,'str',$Baudrate)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc

;ConsoleWrite("_COMClose: "&_COMClose(3)&@CRLF)
;===============================================================================
;
;Function Name: _COMClose($CommPort)
;Description:	This function returns 1 if the port has been successfully closed, 0 on error. Once the port is opened,
;				it stays in locked status, which means that can only be used by the caller application. It can not be
;				used by other software until you close it.
;Parameters:	每 $CommPort: port number (COMx). The same you used to open the port.
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMClose($CommPort)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_Close','int',$CommPort)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc

;ConsoleWrite("_COMSend: "&_COMSend(3,"c1","")&@CRLF)
;ConsoleWrite("_COMSend: "&_COMSend(3,"getrgbi01","")&@CRLF)
;ConsoleWrite("_COMClose: "&_COMClose(3)&@CRLF)
;===============================================================================
;
;Function Name: _COMSend($CommPort,$Command,$ResponseText)
;Description:	This function returns an integer value of 1 and $ResponseText if the command was sent successfully, returns 0 if a
;				Syntax Error or a Timeout was detected and returns -1 for other errors.
;Parameters:	每 $CommPort: port number to be _COMOpen() (COMx).
;				每 $Command: string specifying the Command used by the LED Analyser: c1,getrgbi01 ect
;							There is no need to send the CR + LF characters at the end
;				- $ResponseText: This is the response string returned by the LED Analyser:OK,Syntax Error ect
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMSend($CommPort,$Command,$ResponseText)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_Send','int',$CommPort,'str',$Command,'str',$ResponseText)
	;ConsoleWrite($vDllAns[0]&" "& $vDllAns[1]&$vDllAns[2]& $vDllAns[3]&@CRLF)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    ElseIf $vDllAns[0]=1 Then
		Return $vDllAns[3]
	ElseIf $vDllAns[0]=0 Then
		ConsoleWrite("Syntax Error or a Timeout was detected"&@CRLF)
		Return -1
	ElseIf $vDllAns[0]=-1 Then
		ConsoleWrite("COMport errors"&@CRLF)
		Return -2
    EndIf
EndFunc

;ConsoleWrite("_COMOpenSN: "&_COMOpenSN("024A","57600")&@CRLF)
;===============================================================================
;
;Function Name: _COMOpenSN($SerialNumber,$Baudrate)
;Description:	This function returns 1 if the port has been successfully opened, 0 on error. Once the port is opened,
;				it stays in locked status, which means that can only be used by the caller application. It can not be
;				used by other software until you close it.
;Parameters:	每 $SerialNumber: string specifying the serial number of the LED Analyser.
;				每 $Baudrate: string specifying the baudrate used by the LED Analyser: 9600, 19200, 38400,
;				57600, 115200, 460800, 921600. You can specify the word ※AUTO§ to autodetect the
;				baudrate, but this method is slower.
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMOpenSN($SerialNumber,$Baudrate)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_OpenSN','str',$SerialNumber,'str',$Baudrate)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc

;ConsoleWrite("_COMCloseSN: "&_COMCloseSN("024A")&@CRLF)
;===============================================================================
;
;Function Name: _COMCloseSN($SerialNumber)
;Description:	This function returns 1 if the port has been successfully closed, 0 on error. Once the port is opened,
;				it stays in locked status, which means that can only be used by the caller application. It can not be
;				used by other software until you close it.
;Parameters:	每 $SerialNumber: string specifying the serial number of the LED Analyser.
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMCloseSN($SerialNumber)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_CloseSN','str',$SerialNumber)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc


;ConsoleWrite("_SetCharsToWait: "&_SetCharsToWait(200)&@CRLF)
;ConsoleWrite("_COMSendSN: "&_COMSendSN("024A","getinfo","")&@CRLF)
;ConsoleWrite("_COMSendSN: "&_COMSendSN("024A","getstatus","")&@CRLF)
;ConsoleWrite("_COMCloseSN: "&_COMCloseSN("024A")&@CRLF)
;===============================================================================
;
;Function Name: _COMSendSN($SerialNumber,$Command,$ResponseText)
;Description:	This function returns an integer value of 1 and $ResponseText if the command was sent successfully, returns 0 if a
;				Syntax Error or a Timeout was detected and returns -1 for other errors.
;Parameters:	每 $SerialNumber: string specifying the serial number of the LED Analyser.
;				每 $Command: string specifying the Command used by the LED Analyser: c1,getrgbi01 ect
;							There is no need to send the CR + LF characters at the end
;				- $ResponseText: This is the response string returned by the LED Analyser:OK,Syntax Error ect
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMSendSN($SerialNumber,$Command,$ResponseText)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_SendSN','str',$SerialNumber,'str',$Command,'str',$ResponseText)
	;ConsoleWrite($vDllAns[0]&" "& $vDllAns[1]&$vDllAns[2]& $vDllAns[3]&@CRLF)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    ElseIf $vDllAns[0]=1 Then
		Return $vDllAns[3]
	ElseIf $vDllAns[0]=0 Then
		ConsoleWrite("Syntax Error or a Timeout was detected"&@CRLF)
		Return -1
	ElseIf $vDllAns[0]=-1 Then
		ConsoleWrite("COMport errors"&@CRLF)
		Return -2
    EndIf
EndFunc

;ConsoleWrite("_COMCloseAll: "&_COMCloseAll()&@CRLF)
;===============================================================================
;
;Function Name: _COMCloseAll()
;Description:	This function returns 1 if all the ports hava been successfully closed, 0 on error. Once the port is opened,
;				it stays in locked status, which means that can only be used by the caller application. It can not be
;				used by other software until you close it.
;Parameters:	void
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _COMCloseAll()
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_CloseAll')
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc

;ConsoleWrite("_SetCharsToWait: "&_SetCharsToWait(200)&@CRLF)
;===============================================================================
;
;Function Name:  _SetCharsToWait($NumChars)
;Description:	There are sometimes that are planning to receive long responses, for example when you want to use
;				the LED Analyser commands GETSTATUS, GETINFO. This strings returned contains alot of line feeds,
;				so if you use the default reception settings, only the first line will be received. One solution
;				is to tell the system to receive a certain number of characters instead of wait for a certain string.
;Parameters:	每 $NumChars: an integer with the number of characters to wait in the reception.
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _SetCharsToWait($NumChars)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_SetCharsToWait','int',$NumChars)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc


;ConsoleWrite("_SetStringToWait: "&_SetStringToWait("OK[CRLF]")&@CRLF)
;===============================================================================
;
;Function Name:  _SetStringToWait($StringToWait)
;Description:	By default, when a command is sent to the LED Analyser,
;				the reception finishes when a timeout is detected or an special set of characters
;				is received. You can change this set of characters
;Parameters:	每 $StringToWait: this is the string of characters you set as the ※end of a reception§ identifier. So
;				if StringToWait is equal to ※OK[CRLF]§ the reception will finish when the characters OK +
;				carriage return + line feed will be detected. Independent on the programming language you
;				use, there are several text templates to identify special characters:
;				- ※[CR]§: carriage return
;				- ※[LF]§: line feed
;				- ※[CRLF]§: carriage return + line feed
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _SetStringToWait($StringToWait)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_SetStringToWait','str',$StringToWait)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc

;ConsoleWrite("_SetTimeToWait: "&_SetTimeToWait("1000")&@CRLF)
;===============================================================================
;
;Function Name:  _SetTimeToWait($Timeout)
;Description:	By default, when a command is sent to the LED Analyser,
;				the reception finishes when a timeout is detected or an special set of characters
;				is received. You can change this set of timeout
;Parameters:	每 $Timeout: integer with the value of the desired maximum Timeout (maximum waiting time)
;				for the reception. The maximum value for this parameter is 32000 (32 seconds).
;Returns:		on success - 1
;				on failure - 0 and @error set to DllCall error if it was not found.
;									@error set to 1 if dll not open and couldn't be opened
;
;===============================================================================
Func _SetTimeToWait($Timeout)
	Local $vDllAns
    If Not $fPortOpen Then
        SetError(1)
        Return 0
    EndIf

    $vDllAns = DllCall($hDll,'int','LedAnalyser_SetResponseTimeout','uint',$Timeout)
	If @error <> 0 Then
        SetError(@error)
        Return 0
    Else
        Return $vDllAns[0]
    EndIf
EndFunc