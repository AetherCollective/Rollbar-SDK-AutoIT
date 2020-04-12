# Rollbar SDK for AutoIT
Rollbar provides real-time error alerting & debugging tools for developers. Learn more about it at https://rollbar.com/product/

Demo: https://rollbar.com/demo/demo/

Screenshot:
![https://www.autoitscript.com/forum/uploads/monthly_2019_04/image.thumb.png.5c26313057911c5004969e938536a51c.png](https://www.autoitscript.com/forum/uploads/monthly_2019_04/image.thumb.png.5c26313057911c5004969e938536a51c.png)

Instructions: (RollbarTest.au3)

```autoit
; Include RollbarSDK
#include "RollbarSDK.au3"

;Turns on ConsoleWrite debugging override.
;Global $Rollbar_Debug=False

; Initialize RollbarSDK with the project's API key.
; Parameters ....:  $__Rollbar_sToken   - [Required] Go to https://rollbar.com/<User>/<ProjectName>/settings/access_tokens/ for your project. Use the token for post_server_item.
_Rollbar_Init("eaa8464a4082eeabd9454465b8f0c0af")

; Write code that causes an error you want to catch, then call

; _Rollbar_Send
; Parameters ....:  $__Rollbar_sErrorLevel      - [Required] Must be one of the following values: Debug, Info, Warning, Error, Critical.
;                   $__Rollbar_sMessage         - [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;                   $__Rollbar_sMessageSummary  - [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
_Rollbar_Send("Debug", "This is an debug message. If you received this, you were successful!", "Debug Message")
_Rollbar_Send("Info", "This is a test message. If you received this, you were successful!", "Info Message")
_Rollbar_Send("Warning", "This is an warning message. If you received this, you were successful!", "Warning Message")
_Rollbar_Send("Error", "This is an error message. If you received this, you were successful!", "Error Message")
_Rollbar_Send("Critical", "This is an critical message. If you received this, you were successful!", "Critical Message")
_Rollbar_Send("Info", "This is a test message. If you received this, you were successful!") ;No Message

; Rollbar_Send's helper functions
; Parameters ....:  $__Rollbar_sMessage         - [Required] The message to be sent. This should contain any useful debugging info that will help you debug.
;                   $__Rollbar_sMessageSummary  - [Optional] A string that will be used as the title of the Item occurrences will be grouped into. Max length 255 characters. If omitted, Rollbar will determine this on the backend.
_Rollbar_SendDebug("This is an debug message. If you received this, you were successful!", "Debug Message")
_Rollbar_SendInfo("This is a test message. If you received this, you were successful!", "Info Message")
_Rollbar_SendWarning("This is an warning message. If you received this, you were successful!", "Warning Message")
_Rollbar_SendError("This is an error message. If you received this, you were successful!", "Error Message")
_Rollbar_SendCritical("This is an critical message. If you received this, you were successful!", "Critical Message")

; Usable Example
Local $sImportantFile = "C:\NOTAREALFILE_1234554321.txt"
Switch FileExists($sImportantFile)
    Case True
        MsgBox(0, "Example Script", "An important file was found. Continuing...")
    Case Else
        _Rollbar_SendCritical('An important file was missing. Halting... File: "' & $sImportantFile & '"', 'Important file "' & $sImportantFile & '" is missing.')
EndSwitch
```
