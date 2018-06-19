#include "FeasaDLL.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GuiButton.au3>
#include <Date.au3>
#include <File.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>


Opt("GUIOnEventMode", 0)
Opt('MustDeclareVars', 1)

Global $GUI,$EditCtr,$Start,$TestData,$listview,$PassOrFail,$LEDPOrF,$Label,$ErrorMsg
Global $Filemenu,$fileOpen,$FileOLog,$separator1,$FileExit
Global $Setmenu,$Setdebug,$Setdon,$Setdoff,$separator2,$SetOption
Global $Helpmenu,$HelpRlsNt,$HelpAbt
Global $logfile,$inifile,$FSeri,$Num,$Intensity,$Intensity_B,$debug,$cLEDSplit,$Loop,$Blink=0
$inifile = StringTrimRight(@ScriptName,4)&".ini"
$logfile =  _IniRead(@ScriptDir&"\"&$inifile,"Logfile")
$Loop = _IniRead(@ScriptDir&"\"&$inifile,"Loop")


$FSeri = _IniRead(@ScriptDir&"\"&$inifile,"FeasaSerial")
$Num = _IniRead(@ScriptDir&"\"&$inifile,"Num")
Global $aLED[$Num],$cLED[$Num]
$GUI = GUICreate("FeasaTest Beta V2.0",500, 500) ; will create a dialog box that when displayed is centered
$listview = GUICtrlCreateListView("Item|ColorSet|type|ISet|R|G|B|IRslt|RGBRslt|Status",20,70,460,190);10 token
$Intensity =  _IniRead(@ScriptDir&"\"&$inifile,"Intensity","spec")
For $i=0 To $Num-1 Step 1
   $cLED[$i] = _INIread(@ScriptDir&"\"&$inifile,"LED"&$i+1);LED color in set ini
   ;ConsoleWrite($cLED[$i]&@CRLF)
   $cLEDSplit = StringSplit($cLED[$i],",")
   If $cLEDSplit[2]="B" Then $Blink=1
   If Not StringInStr($CmdLineRaw,"Num")  Then $aLed[$i] = GUICtrlCreateListViewItem("LED"&$i+1&"|"&$cLEDSplit[1]&"|"&$cLEDSplit[2]&"|"&$Intensity&"|0|0|0|0||", $listview)
Next
$debug = _IniRead(@ScriptDir&"\"&$inifile,"debug")

If $CmdLine[0] >= 1 Then
   local $p
   For $i=1 To $CmdLine[0] Step 1
	  $p = StringSplit($CmdLine[$i],":")
	  ;ConsoleWrite("p1:"&$p[1]&@CRLF)
	  Switch $p[1]
	  Case "FeasaSerial"
		 $FSeri = $p[2]
		 ConsoleWrite("Get variable $FSeri value: "&$FSeri&" from cmdline: "&$CmdLine[$i]&@CRLF)
	  Case "Num"
		 $Num = $p[2]
		 Global $aLED[$Num],$cLED[$Num]
		 ConsoleWrite("Get variable $Num value: "&$Num&" from cmdline: "&$CmdLine[$i]&@CRLF)
	  Case "LED1"
		 $cLED[0] = $p[2]
		 ConsoleWrite("Get variable $cLED[0] value: "&$cLED[0]&" from cmdline: "&$CmdLine[$i]&@CRLF)
		 $cLEDSplit = StringSplit($cLED[0],",")
		 If $cLEDSplit[2]="B" Then $Blink=1
		 $aLed[0] = GUICtrlCreateListViewItem("LED1|"&$cLEDSplit[1]&"|"&$cLEDSplit[2]&"|"&$Intensity&"|0|0|0|0||", $listview)
		 
	  Case "LED2"
		 $cLED[1] = $p[2]
		 ConsoleWrite("Get variable $cLED[1] value: "&$cLED[1]&" from cmdline: "&$CmdLine[$i]&@CRLF)
		 $cLEDSplit = StringSplit($cLED[1],",")
		 If $cLEDSplit[2]="B" Then $Blink=1
		 $aLed[1] = GUICtrlCreateListViewItem("LED2|"&$cLEDSplit[1]&"|"&$cLEDSplit[2]&"|"&$Intensity&"|0|0|0|0||", $listview)
		 
	  Case "Intensity"
		 $Intensity = $p[2]
		 ConsoleWrite("Get variable $Intensity value: "&$Intensity&" from cmdline: "&$CmdLine[$i]&@CRLF)
		 ConsoleWrite("The variable $Intensity should define earlier than $Num, or the GUI will show ini set defalt value,but not impact use")
	  Case "debug"
		 $debug = $p[2]
		 ConsoleWrite("Get variable $debug value: "&$debug&" from cmdline: "&$CmdLine[$i]&@CRLF)
	  Case Else
		cmdline_H()
		;MsgBox(0,"Error","Parameter Error!")
		exit(-1)
	  EndSwitch

   Next
   
EndIf
GUISetState(@SW_SHOW,$GUI) ; will display an empty dialog box
Global $aRGBI[$Num],$aR[$Num],$aG[$Num],$aB[$Num]


################ GUI part start ################


	$Filemenu = GUICtrlCreateMenu("&File")
	$FileOpen = GUICtrlCreateMenu("&Open", $Filemenu)
	$FileOLog = GUICtrlCreateMenuItem("LogFile",$FileOpen)
	$separator1 = GUICtrlCreateMenuItem("", $Filemenu)
	$FileExit = GUICtrlCreateMenuItem("&Exit", $Filemenu)

	$Setmenu = GUICtrlCreateMenu("Set&up")
	$Setdebug = GUICtrlCreateMenu("&Debug",$Setmenu)
	$Setdon = GUICtrlCreateMenuItem("ON",$Setdebug)
	$Setdoff = GUICtrlCreateMenuItem("OFF",$Setdebug)
	If $debug=1 then
		GUICtrlSetState($Setdon, $GUI_CHECKED)
	Else
		GUICtrlSetState($Setdoff, $GUI_CHECKED)
	EndIf
	$separator2 = GUICtrlCreateMenuItem("", $setmenu, 2)
	$SetOption = GUICtrlCreateMenuItem("Option",$Setmenu)

	$Helpmenu = GUICtrlCreateMenu("&Help")
	$HelpRlsNt = GUICtrlCreateMenuItem("ReleaseNotes",$Helpmenu)
	$HelpAbt = GUICtrlCreateMenuItem("About",$Helpmenu)

	$Start = GUICtrlCreateButton("Start",35,10,70,30)
	$TestData = GUICtrlCreateGroup("TestData",10,50,480,220)

	$PassOrFail = GUICtrlCreateGroup("PassOrFail",10,270,480,160)
	$Label = GUICtrlCreateLabel("",20,290,465,130,$ES_CENTER)
	GUICtrlSetFont(-1,100)
	;GUICtrlSetBkColor(-1, 0x00ff00)
	$ErrorMsg = GUICtrlCreateLabel("",20,450,465,40)
	GUICtrlSetFont(-1,15)
	GUICtrlSetColor(-1,0xff0000)
	;GUICtrlSetBkColor(-1, 0x00ff00)
################ GUI part end ################

Global $Low,$Mid,$High,$LowSpec,$MidSpec,$HighSpec,$error=0,$Colorspec,$Result
$Low = _iniread(@ScriptDir&"\"&$inifile,"L","spec")
$Mid = _iniread(@ScriptDir&"\"&$inifile,"M","spec")
$High = _iniread(@ScriptDir&"\"&$inifile,"H","spec")

$LowSpec =StringSplit($Low,"~")
$MidSpec =StringSplit($Mid,"~")
$HighSpec =StringSplit($High,"~")
;ConsoleWrite($LowSpec[1]&","&$MidSpec[1]&","&$HighSpec[1]&@CRLF)
;ConsoleWrite($LowSpec[2]&","&$MidSpec[2]&","&$HighSpec[2]&@CRLF)

main()

Func main()
 Local $f
 While $debug=1
		Local $msg
        $msg = GUIGetMsg()
		Switch $msg
		case $GUI_EVENT_CLOSE,$Fileexit
			exit(1)
		Case $Setdon
			GUICtrlSetState($Setdon, $GUI_CHECKED)
			if not $debug=1 Then
				IniWrite($inifile,"SET","debug","1")
				exit(1)
			EndIf
		Case $Setdoff
			GUICtrlSetState($Setdoff, $GUI_CHECKED)
			if not $debug=0 then
				IniWrite($inifile,"SET","debug","0")
				exit(1)
			EndIf
		Case $HelpRlsNt
			RunWait("notepad.exe "&@ScriptDir&"\ReleaseNote.txt")
		Case $HelpAbt
			MsgBox(0,"Help--About","All CopyRight Reserved by USI"&@LF& _
			"Any question,pls contact:"&@LF& _
			"leo_liao@usiglobal.com")
		case $FileOLog
			RunWait("notepad.exe "&$logfile)
		Case $SetOption
			RunWait("notepad.exe "&$inifile)
		Case $Start
			GetRGBI()
			If $error=0 Then
				$f = FileOpen($logfile, 1)
				If $f = -1 Then
					MsgBox(0, "错误", "不能打开文件:"&$logfile)
					exit(1)
				EndIf
				LogWriteConsole($logfile,_NowTime()&" Total Pass")
				GUICtrlSetData($Label,"PASS")
				GUICtrlSetBkColor($Label, 0x00ff00)
				FileClose($f)
			Else
				GUICtrlSetData($Label,"FAIL")
				GUICtrlSetBkColor($Label, 0xff0000)
				FileClose($f)
			EndIf
		EndSwitch
    WEnd

if $debug=0 Then
	GetRGBI()
	If $error=0 Then
		$f = FileOpen($logfile, 1)
		If $f = -1 Then
			MsgBox(0, "错误", "不能打开文件:"&$logfile)
			exit(1)
		EndIf
		LogWriteConsole($logfile,_NowTime()&" Total Pass")
		GUICtrlSetData($Label,"PASS")
		GUICtrlSetBkColor($Label, 0x00ff00)
		FileClose($f)
		Sleep(2000)
		EndMain()
		Exit(0)
	Else
		GUICtrlSetData($Label,"FAIL")
		GUICtrlSetBkColor($Label, 0xff0000)
		FileClose($f)
		Sleep(2000)
		EndMain()
		Exit(1)
	EndIf
EndIf


EndFunc

Func GetRGBI()  ;Get RGBI ready
	$error=0
	GUICtrlSetState($Start,$GUI_DISable)
	local $COMNum,$sErr,$f

	For $i=0 To $Num-1 Step 1 ;clear data frist
		GUICtrlSetBkColor($aLed[$i], 0xffffff)
		GUICtrlSetData($aLed[$i],"||||0|0|0|0| | ")
		GUICtrlSetData($Label,"")
		GUICtrlSetBkColor($Label, 0xffffff)
		GUICtrlSetData($ErrorMSG,"")
	Next
	If Not _FeasaSetDllPath('feasala4.dll') then
		MsgBox(0,"Error","feasala4.dll is not exist")
		Exit(1)
	EndIf
	_COMCloseAll()
	Sleep(500)
	$COMNum = _ComPortsNum()
	ConsoleWrite("COM Num:"&$COMNum&@CRLF)
	;StringSplit($COMNum)

	If $COMNum <=0 Then
		MsgBox(0,"Error","Pls check the Feasa USB cable whether is OK")
		exit(1)
	EndIf
	If Not _FeasaConneted($FSeri,"57600") Then
		MsgBox(0,"error","Can't find the device:"&$FSeri)
		Exit(1)
	EndIf
	If Not _COMOpenSN($FSeri,"57600") Then
		MsgBox(0,"error","Can't Open the port of the device:"&$FSeri)
		Exit(1)
	EndIf

	if FileExists($logfile) Then FileDelete($logfile)
	Sleep(500)
	$f = FileOpen($logfile, 1)
	If $f = -1 Then
		MsgBox(0, "错误", "不能打开文件:"&$logfile)
		exit(1)
	EndIf

	AGetRGBI()
	if $error=0 and $Blink=1 then BgetRGBI()

	FileClose($f)
	GUICtrlSetState($Start,$GUI_ENable)
EndFunc

Func AGetRGBI() ;Always LED test
	Local $Rspns,$aI[$Num]
    _SetTimeToWait("15000")
	$Rspns = _COMSendSN($FSeri,"c1","")
	If Not $Rspns="OK" Then
		MsgBox(0,"Error","COM Port Command error:"&$Rspns)
		exit(1)
	EndIf

	For $i=0 To $Num-1 Step 1 ;once capture get $Num data
		$cLEDSplit = StringSplit($cLED[$i],",")
		If $cLEDSplit[2]="A" Then
			LogWriteConsole($logfile,@CRLF&_NowTime()&" Always LED"&$i+1&" test data:")
			$aRGBI[$i]=_COMSendSN($FSeri,"getrgbi0"&$i+1,"")
			ConsoleWrite(_NowTime()&" A_RGBI["&$i&"]:"&$aRGBI[$i]&@CRLF)
			$aR[$i] = StringLeft($aRGBI[$i],3)
			$aG[$i] = Stringmid($aRGBI[$i],5,3)
			$aB[$i] = Stringmid($aRGBI[$i],9,3)
			$aI[$i] = StringRight($aRGBI[$i],7)
			LogWriteConsole($logfile,"R:"&$aR[$i]&" G:"&$aG[$i]&" B:"&$aB[$i]&" I:"&$aI[$i])
			GUICtrlSetData($aLed[$i],"||||"&$aR[$i]&"|"&$aG[$i]&"|"&$aB[$i]&"|"&$aI[$i]&"||")
			$Colorspec = _iniread(@ScriptDir&"\"&$inifile,$cLEDSplit[1],"spec")
			LogWriteConsole($logfile,"The LED color should be:"&$cLED[$i]&" "&$Colorspec)
			$Result = LMH($aR[$i])&","&LMH($aG[$i])&","&LMH($aB[$i])
			LogWriteConsole($logfile,"The RGB result is:"&$Result)
			GUICtrlSetData($aLed[$i],"||||||||"&$Result&"|")
			If Number($aI[$i]) >= $Intensity and $Colorspec == $Result Then
				GUICtrlSetData($aLed[$i],"|||||||||OK")
				GUICtrlSetBkColor($aLed[$i], 0x00ff00)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" OK"&@CRLF)
				$error=0
			Else
				GUICtrlSetData($ErrorMsg,"LED"&$i+1&" NG")
				GUICtrlSetData($aLed[$i],"|||||||||NG")
				GUICtrlSetBkColor($aLed[$i], 0xff0000)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" NG"&@CRLF)
				$error=$i+1
				ExitLoop
			EndIf
		EndIf
	Next
EndFunc

Func BgetRGBI() ;Blink LED test
	Local $Lightoff[$Loop+1][$Num],$aI[$Num][$Loop+1],$BLED_Exist=0,$data,$Count=0,$OKCount=0
	LogWriteConsole($logfile,@CRLF&_NowTime()&" Blinking LED test data:")
	;$Intensity_B = 2*$Intensity
	For $i=0 To $Num-1 Step 1 ;wrtite section in logfile frist
		$cLEDSplit = StringSplit($cLED[$i],",")
		If $cLEDSplit[2]="B" Then
			IniWriteSection($logfile,"LED"&$i+1,"")
		EndIf
	Next

	For $j=1 To $Loop Step 1 ;try $Loop times and log $Loop times data in section together
		Local $Rspns
		_SetTimeToWait("15000")
		$Rspns = _COMSendSN($FSeri,"c1","")
		If Not $Rspns="OK" Then
			MsgBox(0,"Error","COM Port Command error:"&$Rspns)
			exit(1)
		EndIf
		For $i=0 To $Num-1 Step 1   ;log $Num LED data in section together
			$cLEDSplit = StringSplit($cLED[$i],",")
			If $cLEDSplit[2]="B" Then
				$aRGBI[$i]=_COMSendSN($FSeri,"getrgbi0"&$i+1,"")
				ConsoleWrite(_NowTime()&" B_RGBI["&$i&"]:"&$aRGBI[$i])
				$aR[$i] = StringLeft($aRGBI[$i],3)
				$aG[$i] = Stringmid($aRGBI[$i],5,3)
				$aB[$i] = Stringmid($aRGBI[$i],9,3)
				$aI[$i][$j] = Stringmid($aRGBI[$i],13,5)
				IniWrite($logfile,"LED"&$i+1,$j,"R:"&$aR[$i]&" G:"&$aG[$i]&" B:"&$aB[$i]&" I:"&$aI[$i][$j])
				#cs              ==>disable judge if lightoff according $aI[$i]
				Switch $aI[$i]
				Case $aI[$i] <= 2*12000                          ;$aI[$i]:(0,24000]
					If Abs($aI[$i] - $Intensity_B) >= 4000 Then  ;与上一次的差值大于4000，即为闪过一次
						$Lightoff[$j][$i]=1
					Else
						$Lightoff[$j][$i]=0
					EndIf
				Case $aI[$i] <= 4*12000 And $aI[$i] > 2*12000    ;$aI[$i]:(24000,48000]
					If Abs($aI[$i] - $Intensity_B) >= 6000 Then  ;与上一次的差值大于6000，即为闪过一次
						$Lightoff[$j][$i]=1
					Else
						$Lightoff[$j][$i]=0
					EndIf
				case Else                                        ;$aI[$i]:(48000,92000] or more
					If Abs($aI[$i] - $Intensity_B) >= 8000 Then  ;与上一次的差值大于8000，即为闪过一次
						$Lightoff[$j][$i]=1
					Else
						$Lightoff[$j][$i]=0
					EndIf
				EndSwitch

				if Number($aI[$i]) >= Number($Intensity) Then $Intensity_B = $aI[$i] ;保存上一次的值
				;ConsoleWrite("$aI[$i]:"&Number($aI[$i])&" $Intensity:"&Number($Intensity)&@CRLF)
				ConsoleWrite("$Intensity_B:"&$Intensity_B&@CRLF)
				ConsoleWrite("$Lightoff["&$j&"]["&$i&"]:"&$Lightoff[$j][$i]&@CRLF)
				#ce
				If $j>=2 Then
					If Abs($aI[$i][$j] - $aI[$i][$j-1]) >= 4000 Then  ;与上一次的差值大于4000，B LED exist
						$BLED_Exist=1
					EndIf
				EndIf
				ConsoleWrite($j&": BLED_Exist:"&$BLED_Exist&@CRLF)
				GUICtrlSetData($aLed[$i],"||||"&$aR[$i]&"|"&$aG[$i]&"|"&$aB[$i]&"|"&$aI[$i][$j]&"||")

			EndIf

		Next
			ConsoleWrite(_NowTime()&" Loop"&$j&" complete"&@CRLF&@CRLF)
			;GUICtrlSetData($ErrorMsg,_NowTime()&"Loop"&$j&" complete")

	Next

	For	$i=0 To $Num-1 Step 1  ;try to find Blinking LED if exist and deal with the $Loop times data
		$cLEDSplit = StringSplit($cLED[$i],",")
		$error=0
		If $cLEDSplit[2]="B" Then
			For $j=1 To $Loop Step 1  ;if disable judge if lightoff according $aI[$i],$j=1; else find Blinking LED if exist,the 1st time are not included because it is a sample
				;ConsoleWrite("$Lightoff["&$j&"]["&$i&"]:"&$Lightoff[$j][$i]&@CRLF)
				;If $Lightoff[$j][$i]=1 Then
					;$BLED_Exist=1
					;$Count=$Count+1
				;Else
					$data = IniRead($logfile,"LED"&$i+1,$j,"Not find")
					$aR[$i] = Stringmid($data,3,3)
					$aG[$i] = Stringmid($data,9,3)
					$aB[$i] = Stringmid($data,15,3)
					$aI[$i][$j] = StringRight($data,5)
					ConsoleWrite($aR[$i]&" "&$aG[$i]&" "&$aB[$i]&" "&$aI[$i][$j]&" "&@CRLF)
					$Colorspec = _iniread(@ScriptDir&"\"&$inifile,$cLEDSplit[1],"spec")
					$Result = LMH($aR[$i])&","&LMH($aG[$i])&","&LMH($aB[$i])
					ConsoleWrite("RGBRslt:"&$Result&" spec:"&$Colorspec&@CRLF)
					If Number($aI[$i][$j]) >= $Intensity and $Colorspec == $Result Then
						ConsoleWrite("the "&$j&" time:LED"&$i+1&" Lighting OK"&@CRLF&@CRLF)
						$OKCount=$OKCount+1
					#cs     ==>disable NG abrupt
					Else
						GUICtrlSetData($ErrorMsg,"the "&$j&" time:LED"&$i+1&" Lighting NG")
						GUICtrlSetData($aLed[$i],"|||||||||NG")
						GUICtrlSetBkColor($aLed[$i], 0xff0000)
						LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" NG")
						$error=$i+1
						ExitLoop
					#ce
					EndIf
				;EndIf

			Next
			#cs       ==>disable judge $Count
			If $Count=$Loop-1 Then
				$error=-1
				GUICtrlSetData($ErrorMsg,"LED"&$i+1&" is no lighting")
				GUICtrlSetData($aLed[$i],"|||||||||NG")
				GUICtrlSetBkColor($aLed[$i], 0xff0000)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" NG")
				ExitLoop
			EndIf
			#ce
			;If not $error=0 Then  ;in $Loop times there is one of the error out of 0
			If $OKCount=0 Then  ;in $Loop times there is no once OK
				$error=-1
				GUICtrlSetData($ErrorMsg,"LED"&$i+1&" is no once lighting OK")
				GUICtrlSetData($aLed[$i],"||||||||"&$Result&"|")
				GUICtrlSetData($aLed[$i],"|||||||||NG")
				GUICtrlSetBkColor($aLed[$i], 0xff0000)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" is no once lighting OK")
				ExitLoop
			ElseIf $BLED_Exist=0 Then
				;ConsoleWrite("LED"&$i+1&" is not a blinking LED"&@CRLF)
				LogWriteConsole($logfile,"LED"&$i+1&" is not a blinking LED")
				GUICtrlSetData($ErrorMsg,"LED"&$i+1&" is not a blinking LED")
				GUICtrlSetData($aLed[$i],"||||||||"&$Result&"|")
				GUICtrlSetData($aLed[$i],"|||||||||NG")
				GUICtrlSetBkColor($aLed[$i], 0xff0000)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" NG"&@CRLF)
				$error=$i+1
				ExitLoop
			Else
				GUICtrlSetData($aLed[$i],"||||||||"&$Result&"|")
				GUICtrlSetData($aLed[$i],"|||||||||OK")
				GUICtrlSetBkColor($aLed[$i], 0x00ff00)
				;LogWriteConsole($logfile,_NowTime()&" the total "&$j-1&" times LED"&$i+1&" Lighting OK"&@CRLF)
				LogWriteConsole($logfile,_NowTime()&" in the total "&$j-1&" times,there are "& _
				$OKCount&" times LED"&$i+1&" Lighting OK"&@CRLF)
			EndIf
			#cs       ==>disable judge $BLED_Exist
			if not $BLED_Exist=1 Then   ;in $Loop times there is no once light-off
				;ConsoleWrite("LED"&$i+1&" is not a blinking LED"&@CRLF)
				LogWriteConsole($logfile,"LED"&$i+1&" is not a blinking LED")
				GUICtrlSetData($ErrorMsg,"LED"&$i+1&" is not a blinking LED")
				GUICtrlSetData($aLed[$i],"|||||||||NG")
				GUICtrlSetBkColor($aLed[$i], 0xff0000)
				LogWriteConsole($logfile,_NowTime()&" LED"&$i+1&" NG"&@CRLF)
				$error=$i+1
				ExitLoop
			EndIf
			#ce
		EndIf
	Next

EndFunc

Func LMH($x) ;$x=R or G or B
	$x=Number($x)
	Select
	Case ($x<= $LowSpec[2]) And ($LowSpec[1]<= $x)
		Return "L"
	Case ($x <= $MidSpec[2]) And ($MidSpec[1] <= $x)
		Return "M"
	Case ($x <= $HighSpec[2]) And ($HighSpec[1]<= $x)
		Return "H"
	EndSelect
EndFunc

Func _INIread($x,$y,$z="SET") ;$x=file to read,$y=keyword,$z=section
Local $value
$value = IniRead($x,$z,$y,"Not Find")
If $value="Not Find" Then
	MsgBox(0,"Error","Pls check the "&$x&"'s "&$y&" whether is OK")
	exit(1)
EndIf
Return $value
EndFunc

Func EndMain()
_COMCloseAll()
GUIDelete($GUI)
EndFunc

Func LogWriteConsole($x,$y);$x=Logfile,$y=String to write
	FileWriteLine($x,$y)
	ConsoleWrite($y&@CRLF)

EndFunc

Func cmdline_H()
	ConsoleWrite("Parameter Error!"&@CRLF)
	ConsoleWrite("The support cmdline list as below: "&@CRLF)
	ConsoleWrite("FeasaSerial:[x] eg:FeasaSerial:2C99"&@CRLF)
	ConsoleWrite("Num:[x] x is a number from 1~50(depends on the Feasa Model) eg:Num:1"&@CRLF)
	ConsoleWrite("LED1:[Red/Green/Blue...,A/B] eg:LED1:Red,A"&@CRLF)
	ConsoleWrite("LED2:[Red/Green/Blue...,A/B] The same as LED1, cmdline only support define LED1 and LED2"&@CRLF)
	ConsoleWrite("Intensity:[x] x is a number from 1~999999999 eg:Intensity:10000"&@CRLF)
	ConsoleWrite("Debug:[0/1] eg:Debug:1"&@CRLF)
EndFunc