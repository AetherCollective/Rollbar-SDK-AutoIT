#include-once
#include <Date.au3>
#include <MsgBoxConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: Rollbar
; AutoIt Version : 3.3.14.5
; Language.......: English (Multilingual Capable)
; UDF Version ...: 0.2
; Description ...: Windows API calls that have been translated to AutoIt functions.
; Author(s) .....: BetaLeaf, Guinness (_DateToEpoch & _EpochToDate)
; Forum link ....: https://www.autoitscript.com/forum/topic/198704-rollbar-udf/
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _DateToEpoch
; _EpochToDate
; _Rollbar_ApiPing
; _Rollbar_CreateItem
; _Rollbar_Init
; _Rollbar_Init_Ask
; _Rollbar_SanitizeString
; _Rollbar_Send
; _Rollbar_SendCritical
; _Rollbar_SendDebug
; _Rollbar_SendError
; _Rollbar_SendInfo
; _Rollbar_SendItem
; _Rollbar_SendWarning
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__G_Rollbar_bDebug = False ; Set true to enable ConsoleWrite Debugging. WARNING: THIS WILL EXPOSE YOUR API KEY!!!
Global $__G_Rollbar_sToken = "" ;To be filled by _Rollbar_Init or _Rollbar_Init_Ask from program.
Global $__G_Rollbar_sAPIBase = "https://api.rollbar.com/api/1/" ;The current API base url. Supports version 1.
Global $__G_Rollbar_sUDFVersion = "v0.2"
If StringRight(@ScriptName, 4) = ".au3" Then Global $__Rollbar_bDebug = True ; Comment line out to disable debugging when ran as .au3 file. (click on line, then press numpad minus)
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__G_Rollbar_Strings_InitAsk_sTitle = "Rollbar Automatic Bug Reporter"
Global Const $__G_Rollbar_Strings_InitAsk_sText = "This application is capable of sending automatic bug reports. Would you like to enable this feature?" & @CRLF & _
		@CRLF & _
		"We collect the following information when enabled:" & @CRLF
Global Const $__G_Rollbar_Strings_InitAsk_UserData = _
		'Windows Version: "' & @OSVersion & ': ' & @OSBuild & ' - ' & StringLower(@OSArch) & ' ' & @OSServicePack & '"' & @CRLF & _
		'Username: "' & @UserName & '"' & @CRLF & _
		'Working Directory: "' & @ScriptDir & '"'
Global Const $__G_Rollbar_Strings_InitAsk_sPrivacyInfo = ""
Global Const $__G_Rollbar_Strings_InitAsk_sResponseTrue = "Thank you for enabling automatic bug reports. You can disable this function by deleting this file:"
Global Const $__G_Rollbar_Strings_InitAsk_sResponseFalse = "Automatic bug reporting has been disabled. You can enable this function by deleting this file:"
Global Const $__G_Rollbar_Strings_InitAsk_sSaveError = "Could not save file:"
Global Const $__G_Rollbar_Strings_IniFile_sDebugging = "Debugging"
Global Const $__G_Rollbar_Strings_Ini_sSection = "Reporting"
Global Const $__G_Rollbar_Strings_Ini_sKey = "Enabled"
Global Const $__G_Rollbar_Strings_Console_sInit = "Rollbar Initialized!. Let's squash some bugs."
Global Const $__G_Rollbar_Strings_Console_sInitOptOut = "Rollbar was disabled by the user."
Global Const $__G_Rollbar_Strings_Console_sErrorLevel = "Could not set ErrorLevel."
Global Const $__G_Rollbar_Strings_Console_sHTTP200 = "HTTP Response 200 - OK:	Operation was completed successfully."
Global Const $__G_Rollbar_Strings_Console_sHTTP400 = "HTTP Response 400 - Bad request:	The request was malformed and could not be parsed."
Global Const $__G_Rollbar_Strings_Console_sHTTP403 = "HTTP Response 403 - Access denied:	Access token was missing, invalid, or does not have the necessary permissions."
Global Const $__G_Rollbar_Strings_Console_sHTTP404 = "HTTP Response 404 - Not found:	This response will be returned if the URL is entirely invalid (i.e. /asdf), or if it is a URL that could be valid but is referencing something that does not exist (i.e. /item/12345)."
Global Const $__G_Rollbar_Strings_Console_sHTTP413 = "HTTP Response 413 - Request entity too large:	The request exceeded the maximum size of 128KB."
Global Const $__G_Rollbar_Strings_Console_sHTTP422 = "HTTP Response 422 - Unprocessable Entity:	The request was parseable (i.e. valid JSON), but some parameters were missing or otherwise invalid."
Global Const $__G_Rollbar_Strings_Console_sHTTP429 = "HTTP Response 429 - Too Many Requests:	If rate limiting is enabled for your access token, this Return SetError(code signifies that the rate limit has been reached and the item was not processed."
Global Const $__G_Rollbar_Strings_Console_sHTTPResponse = "HTTP Response"
Global Const $__G_Rollbar_Strings_Console_sTitle = "Rollbar"
Global Const $__G_Rollbar_Strings_Console_sHTTPUndocumented = "This is an undocumented response code."
Global Const $__G_Rollbar_Strings_Console_sPostRequest = "Sending POST Request to Rollbar. Data:"
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _DateToEpoch
; Description ...: Converts the supplied epoch time into date and time.
; Syntax.........: _DateToEpoch($__Rollbar_sDate)
; Parameters ....: $__Rollbar_sDate	- [Required] Date & time in YYYY/MM/DD HH:MM:SS format.
; Return values .: Epoch time
; Author ........: Guinness, Modified by Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _EpochToDate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _DateToEpoch($__Rollbar_sDate)
	Return Int(_DateDiff('s', '1970/01/01 00:00:00', $__Rollbar_sDate))
EndFunc   ;==>_DateToEpoch

; #FUNCTION# ====================================================================================================================
; Name...........: _EpochToDate
; Description ...: Converts the supplied date & time into epoch time
; Syntax.........: _EpochToDate($__Rollbar_iEpoch)
; Parameters ....: $__Rollbar_iEpoch	- Epoch time
; Return values .: Date & time in YYYY/MM/DD HH:MM:SS format.
; Author ........: Guinness, Modified by Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _DateToEpoch
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _EpochToDate($__Rollbar_iEpoch)
	Return _DateAdd('s', $__Rollbar_iEpoch, '1970/01/01 00:00:00')
EndFunc   ;==>_EpochToDate

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Rollbar_ApiPing()
; Description ...: Debug function to test _Rollbar_ API availibility.
; Syntax.........: _Rollbar_ApiPing()
; Parameters ....: None
; Return values .: Success	- Returns True when ping is successful.
;				   Failure	- Returns False when ping fails.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......: Not currently used. For internal testing purposes.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_ApiPing()
	Local $__Rollbar_ApiPing_sTestURL = "https://api.rollbar.com/api/1/status/ping"
	Local $__Rollbar_ApiPing_sExpectedResponse = "pong"
	If InetRead($__Rollbar_ApiPing_sTestURL, 1) = $__Rollbar_ApiPing_sExpectedResponse Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_Rollbar_ApiPing

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_CreateItem
; Description ...: Generates the basic JSON data required to submit an automatic bug report. Calls _Rollbar_SendItem afterwards and returns it's value.
; Syntax.........: _Rollbar_CreateItem($__Rollbar_sErrorLevel, $__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sErrorLevel		- [Required] Must be one of the following values: Debug, Info, Warning, Error, Critical.
;				   $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......: Use _Rollbar_Send instead. This is a backwards compatibility function and should be used internally only.
; Related .......: _Rollbar_Send, _Rollbar_SendDebug, _Rollbar_SendInfo, _Rollbar_SendWarning, _Rollbar_SendError, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_CreateItem($__Rollbar_sErrorLevel, $__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	; If API key is an empty string, user disabled automatic reporting.
	If $__G_Rollbar_sToken = "" Then Return False

	; Get current epoch Time.
	Local $__Rollbar_sRequestTimestamp = _DateToEpoch(_NowCalc())

	; Sanatize Message
	Local $__Rollbar_sSanitizedMessage = _Rollbar_SanitizeString($__Rollbar_sMessage)
	If StringLen($__Rollbar_sMessage) = 0 Then $__Rollbar_sSanitizedMessage = ""

	; Sanatize Root
	Local $__Rollbar_sSanitizedRoot = _Rollbar_SanitizeString(@ScriptDir)
	If StringLen(@ScriptDir) = 0 Then $__Rollbar_sSanitizedRoot = ""

	; Sanatize Message Summary
	Local $__Rollbar_sSanitizedMessageSummary = _Rollbar_SanitizeString(StringLeft($__Rollbar_sMessageSummary, 255))
	If StringLen($__Rollbar_sMessageSummary) = 0 Then $__Rollbar_sSanitizedMessageSummary = ""

	; Prepare JSON Data
	Local $__Rollbar_sJSONData = '{"access_token":"' & $__G_Rollbar_sToken & '","data":{"environment":"production","body":{"message":{"body":"' & $__Rollbar_sSanitizedMessage & '"}},"level":"' & $__Rollbar_sErrorLevel & '","timestamp":"' & $__Rollbar_sRequestTimestamp & '","platform":"windows","language":"autoit","person":{"id":"' & StringLeft(@UserName, 40) & '","username":"' & StringLeft(@UserName, 255) & '"},"server":{"cpu":"' & @OSVersion & ': ' & @OSBuild & ' - ' & StringLower(@OSArch) & ' ' & @OSServicePack & '","root":"' & $__Rollbar_sSanitizedRoot & '"},"title":"' & $__Rollbar_sSanitizedMessageSummary & '","notifier":{"name":"autoit_rollbar","version":"' & $__G_Rollbar_sUDFVersion & '"}}}'

	; Send Item via CreateItem API.
	Local $__Rollbar_sReturn = _Rollbar_SendItem($__Rollbar_sJSONData)

	Return $__Rollbar_sReturn
EndFunc   ;==>_Rollbar_CreateItem
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_Init
; Description ...: Initialize necessary Rollbar variable with API Token.
; Syntax.........:  _Rollbar_Init([$__Rollbar_sToken)
; Parameters ....: $__Rollbar_sToken   - [Required] Go to https://rollbar.com/<User>/<ProjectName>/settings/access_tokens/ for your project. Use the token for post_server_item.
; Return values .: Success		- Returns True when API key is defined.
;				   Failure		- Returns False when API key is empty.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Init_Ask
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_Init($__Rollbar_sToken)
	$__G_Rollbar_sToken = $__Rollbar_sToken
	Select
		Case $__G_Rollbar_sToken = ""
			Return False
		Case Else
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sInit & @CRLF)
			Return True
	EndSelect
EndFunc   ;==>_Rollbar_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_Init
; Description ...: Ask the user for permission to enable automatic bug reporting, then initialize necessary Rollbar variable with API Token accordingly.
; Syntax.........:  _Rollbar_Init([$__Rollbar_sToken)
; Parameters ....: $__Rollbar_sToken   - [Required] Go to https://rollbar.com/<User>/<ProjectName>/settings/access_tokens/ for your project. Use the token for post_server_item.
; Return values .: Success		- Returns True when API key is defined.
;				   Failure		- Returns False when API key is empty.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Init
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_Init_Ask($__Rollbar_sToken)
	; Check if user has already approved automatic error reporting
	Select

		; if approved, init _Rollbar_ with valid API keys.
		Case IniRead(@ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini", $__G_Rollbar_Strings_Ini_sSection, $__G_Rollbar_Strings_Ini_sKey, "") = "True"
			$__G_Rollbar_sToken = $__Rollbar_sToken
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sInit & @CRLF)
			Return True

			; if disapproved, init _Rollbar_ with an empty string.
		Case IniRead(@ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini", $__G_Rollbar_Strings_Ini_sSection, $__G_Rollbar_Strings_Ini_sKey, "") = "False"
			$__G_Rollbar_sToken = ""
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sInitOptOut & @CRLF)
			Return False

			; no user preference
		Case Else

			; Ask user if they want to enable automatic error reporting.
			If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $__G_Rollbar_Strings_InitAsk_sTitle, $__G_Rollbar_Strings_InitAsk_sText & @CRLF & @CRLF & $__G_Rollbar_Strings_InitAsk_UserData & @CRLF & @CRLF & $__G_Rollbar_Strings_InitAsk_sPrivacyInfo) = $idyes Then

				; enable and save settings
				If IniWrite(@ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini", $__G_Rollbar_Strings_Ini_sSection, $__G_Rollbar_Strings_Ini_sKey, "True") = 1 Then
					MsgBox($MB_ICONQUESTION + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $__G_Rollbar_Strings_InitAsk_sTitle, $__G_Rollbar_Strings_InitAsk_sResponseTrue & " " & @ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini")
				Else
					MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $__G_Rollbar_Strings_InitAsk_sTitle, $__G_Rollbar_Strings_InitAsk_sSaveError & " " & @ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini")
				EndIf
				$__G_Rollbar_sToken = $__Rollbar_sToken
				If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sInit & @CRLF)
				Return True
			Else

				; disable and save setting
				If IniWrite(@ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini", $__G_Rollbar_Strings_Ini_sSection, $__G_Rollbar_Strings_Ini_sKey, "False") = 1 Then
					MsgBox($MB_ICONQUESTION + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $__G_Rollbar_Strings_InitAsk_sTitle, $__G_Rollbar_Strings_InitAsk_sResponseFalse & " " & @ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini")
				Else
					MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $__G_Rollbar_Strings_InitAsk_sTitle, $__G_Rollbar_Strings_InitAsk_sSaveError & " " & @ScriptDir & "\" & StringTrimRight(@ScriptName, 4) & "_" & $__G_Rollbar_Strings_IniFile_sDebugging & ".ini")
				EndIf
				$__G_Rollbar_sToken = ""
				If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sInitOptOut & @CRLF)
				Return False
			EndIf
	EndSelect
EndFunc   ;==>_Rollbar_Init_Ask

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SanitizeString
; Description ...: Sanitizes JSON data.
; Syntax.........: _Rollbar_SanitizeString($__Rollbar_sString)
; Parameters ....: $__Rollbar_sString	- [Required] String to sanitize.
; Return values .: Returns a sanitized string.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SanitizeString($__Rollbar_sString)
	Local $__Rollbar_sSanatizedString = $__Rollbar_sString
	$__Rollbar_sSanatizedString = StringReplace($__Rollbar_sSanatizedString, "\", "\\")
	$__Rollbar_sSanatizedString = StringReplace($__Rollbar_sSanatizedString, "<", "\<")
	$__Rollbar_sSanatizedString = StringReplace($__Rollbar_sSanatizedString, ">", "\>")
	$__Rollbar_sSanatizedString = StringReplace($__Rollbar_sSanatizedString, "'", "\'")
	$__Rollbar_sSanatizedString = StringReplace($__Rollbar_sSanatizedString, '"', '\"')
	Return $__Rollbar_sSanatizedString
EndFunc   ;==>_Rollbar_SanitizeString

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_Send
; Description ...: Generates the basic JSON data required to submit an automatic bug report. Calls _Rollbar_SendItem afterwards and returns it's value.
; Syntax.........: _Rollbar_Send($__Rollbar_sErrorLevel, $__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sErrorLevel		- [Required] Must be one of the following values: Debug, Info, Warning, Error, Critical.
;				   $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......: This is the intended way to send a bug report.
; Related .......: _Rollbar_CreateItem, _Rollbar_SendDebug, _Rollbar_SendInfo, _Rollbar_SendWarning, _Rollbar_SendError, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_Send($__Rollbar_sErrorLevel, $__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem($__Rollbar_sErrorLevel, $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_Send

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendCritical
; Description ...: Helper function for _Rollbar_Send with Critical errorlevel.
; Syntax.........: _Rollbar_SendCritical($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Send, _Rollbar_SendDebug, _Rollbar_SendInfo, _Rollbar_SendWarning, _Rollbar_SendError
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SendCritical($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem("Critical", $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_SendCritical

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendDebug
; Description ...: Helper function for _Rollbar_Send with Debug errorlevel.
; Syntax.........: _Rollbar_SendDebug($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Send, _Rollbar_SendInfo, _Rollbar_SendWarning, _Rollbar_SendError, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SendDebug($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem("Debug", $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_SendDebug

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendError
; Description ...: Helper function for _Rollbar_Send with Error errorlevel.
; Syntax.........: _Rollbar_SendError($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Send, _Rollbar_SendDebug, _Rollbar_SendInfo, _Rollbar_SendWarning, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SendError($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem("Error", $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_SendError

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendInfo
; Description ...: Helper function for _Rollbar_Send with Info errorlevel.
; Syntax.........: _Rollbar_SendInfo($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Send, _Rollbar_SendDebug, _Rollbar_SendWarning, _Rollbar_SendError, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SendInfo($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem("Info", $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_SendInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendItem
; Description ...: Sends the supplied JSON data to Rollbar REST API
; Syntax.........: _Rollbar_SendItem($__Rollbar_sJSONData)
; Parameters ....: $__Rollbar_sJSONData	- [Required] A string that contains the JSON data required to create an item occurance on Rollbar.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......: You can create the basic json structure easily with _Rollbar_CreateItem.
; Related .......:
; Link ..........: See https://docs.rollbar.com/reference#items for advanced JSON usage.
; Example .......: No
; ===============================================================================================================================
; Send Item via CreateItem API.
Func _Rollbar_SendItem($__Rollbar_sJSONData)
	; If API key is an empty string, user disabled automatic reporting.
	If $__G_Rollbar_sToken = "" Then Return False

	If $__Rollbar_bDebug = True Then ConsoleWrite($__G_Rollbar_Strings_Console_sPostRequest & " " & $__Rollbar_sJSONData & @CRLF)

	; Send POST Request
	Local $__Rollbar_oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$__Rollbar_oHTTP.Open("POST", $__G_Rollbar_sAPIBase & "item/", False)
	$__Rollbar_oHTTP.Send(StringToBinary($__Rollbar_sJSONData, 1))

	; Read POST Reply
	Local $__Rollbar_iReceived = Int($__Rollbar_oHTTP.Status)
	Local $__Rollbar_sReceived = $__Rollbar_oHTTP.ResponseText

	If $__Rollbar_bDebug = True Then ConsoleWrite($__Rollbar_sReceived & @CRLF)

	; Process Response Code
	Switch $__Rollbar_iReceived
		Case 200
			; Good job!
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP200 & @CRLF)
			Return SetError(False, 200, True)

		Case 400
			; Bug in SDK
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP400 & @CRLF)
			Return SetError(True, 400, False)

		Case 403
			; Bug in Program
			; $__G_Rollbar_sToken is either not set or invalid. See Function _Rollbar_Init()
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP403 & @CRLF)
			Return SetError(True, 403, False)

		Case 404
			; Bug in SDK
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP404 & @CRLF)
			Return SetError(True, 404, False)

		Case 413 ; Bug in Program.
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP413 & @CRLF)
			Return SetError(True, 413, False)

		Case 422
			; Bug in SDK
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP422 & @CRLF)
			Return SetError(True, 422, False)

		Case 429 ;
			; Not a bug; "As a safeguard, the system rate limit for all tokens is initially set to 5,000 events per minute. If you'd like to set a higher rate limit on any of your access tokens (e.g. 10,000 calls per minute), you can do so by contacting support@rollbar.com."
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTP429 & @CRLF)
			Return SetError(True, 0, False)

		Case Else
			; Bug in SDK.
			If $__Rollbar_bDebug = True Then ConsoleWrite("[" & $__G_Rollbar_Strings_Console_sTitle & "] " & $__G_Rollbar_Strings_Console_sHTTPResponse & " " & $__Rollbar_iReceived & ". " & $__G_Rollbar_Strings_Console_sHTTPUndocumented & @CRLF)
			Return SetError(True, $__Rollbar_iReceived, False)

	EndSwitch
EndFunc   ;==>_Rollbar_SendItem

; #FUNCTION# ====================================================================================================================
; Name...........: _Rollbar_SendWarning
; Description ...: Helper function for _Rollbar_Send with Warning errorlevel.
; Syntax.........: _Rollbar_SendWarning($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
; Parameters ....: $__Rollbar_sMessage			- [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;				   $__Rollbar_sMessageSummary	- [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
; Return values .: Success	- Returns True if item occurance was created.
;				   @error contains the opposite value of the Return value.
;				   @expanded contains the HTTP Response Code.
;				   If $__G_Rollbar_sToken is not initialized with _Rollbar_Init or _Rollbar_Init_Ask, then returns False instead.
; Author ........: Jeff Savage (BetaLeaf)
; Modified.......:
; Remarks .......:
; Related .......: _Rollbar_Send, _Rollbar_SendDebug, _Rollbar_SendInfo, _Rollbar_SendError, _Rollbar_SendCritical
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Rollbar_SendWarning($__Rollbar_sMessage, $__Rollbar_sMessageSummary = "")
	Return _Rollbar_CreateItem("Warning", $__Rollbar_sMessage, $__Rollbar_sMessageSummary)
EndFunc   ;==>_Rollbar_SendWarning
