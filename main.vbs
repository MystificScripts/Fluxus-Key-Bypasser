Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim checkpoints(3)
checkpoints(1) = "https://fluxteam.net/windows/checkpoint/check1.php"
checkpoints(2) = "https://fluxteam.net/windows/checkpoint/check2.php"
checkpoints(3) = "https://fluxteam.net/windows/checkpoint/main.php"

strHwProfileGuid = ""
Set objReg = GetObject("winmgmts:\\.\root\default:StdRegProv")
strKeyPath = "SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001"
strValueName = "HwProfileGuid"
objReg.GetStringValue &H80000002, strKeyPath, strValueName, strHwProfileGuid

strHwProfileGuid = Replace(Replace(strHwProfileGuid, "{", ""), "}", "")
strHwProfileGuid = Replace(strHwProfileGuid, "-", "")

strSystemManufacturer = ""
strKeyPath = "SYSTEM\CurrentControlSet\Control\SystemInformation"
strValueName = "SystemManufacturer"
objReg.GetStringValue &H80000002, strKeyPath, strValueName, strSystemManufacturer

strHWID = strHwProfileGuid & strSystemManufacturer

WScript.Echo "HwProfileGuid: " & strHwProfileGuid
WScript.Echo "SystemManufacturer: " & strSystemManufacturer
WScript.Echo "HWID: " & strHWID
WScript.Echo ""

WScript.Echo "Starting checkpoints..."
WScript.Echo ""

strUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:113.0) Gecko/20100101 Firefox/113.0"

For i = 0 To 3
    If i = 0 Then
        strReferer = "https://flux.li/windows/start.php"
    Else
        strReferer = "https://linkvertise.com/"
    End If

    strCommand = "curl.exe -o temp.txt -H ""User-Agent: " & strUserAgent & """ --referer """ & strReferer & """ --data ""HWID=" & strHWID & """ " & checkpoints(i)
    objShell.Run strCommand, 0, True

    If i = 3 Then
        Set objFile = objFSO.OpenTextFile("temp.txt", 1)
        strContents = objFile.ReadAll
        objFile.Close

        Set objRegEx = New RegExp
        objRegEx.Global = True
        objRegEx.IgnoreCase = True
        WScript.Echo("THE RANDOM LETTERS ARE YOUR CODE THIS IS KINDA SHIT BUT I WAS LAZY !! SO KYS IF Y DONT LIEK IT")
        WScript.Echo("ANYTHING AFTER LINE 700> IS YA CODE")
        objRegEx.Pattern = "<code.*?style=""background:#29464A;([\s\S]*?)<\/code>"
        Set matches = objRegEx.Execute(strContents)

        If matches.Count > 0 Then
            strCode = matches(0).SubMatches(0)
            WScript.Echo "Extracted code: " & strCode
        End If
    End If
Next

objFSO.DeleteFile "temp.txt"

WScript.Echo "Press any key to exit..."
WScript.StdIn.Read(1)
