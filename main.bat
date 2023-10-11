@echo off
setlocal enabledelayedexpansion

set checkpoints[0]=https://flux.li/windows/start.php?updated_browser=true
set checkpoints[1]=https://fluxteam.net/windows/checkpoint/check1.php
set checkpoints[2]=https://fluxteam.net/windows/checkpoint/check2.php
set checkpoints[3]=https://fluxteam.net/windows/checkpoint/main.php

for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001" /v "HwProfileGuid" ^| findstr "REG_SZ"') do (
    set HwProfileGuid=%%A
    set HwProfileGuid=!HwProfileGuid:{=!
    set HwProfileGuid=!HwProfileGuid:}=!
    set HwProfileGuid=!HwProfileGuid:-=!
)

for /f "tokens=3*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SystemInformation" /v "SystemManufacturer" ^| findstr "REG_SZ"') do (
    set SystemManufacturer=%%B
)

set "HWID=!HwProfileGuid!!SystemManufacturer!"

echo HwProfileGuid: !HwProfileGuid!
echo SystemManufacturer: !SystemManufacturer!
echo HWID: !HWID!
echo.
echo Starting checkpoints...
echo.

set "UserAgent=Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:113.0) Gecko/20100101 Firefox/113.0"

for /l %%i in (0,1,3) do (
    if %%i equ 0 (
        set "Referer=https://flux.li/windows/start.php"
    ) else (
        set "Referer=https://linkvertise.com/"
    )

    curl.exe -o temp.txt -H "User-Agent: !UserAgent!" --referer "!Referer!" --data "HWID=!HWID!" !checkpoints[%%i]!

    if %%i equ 3 (
        powershell -command "(Get-Content temp.txt | Select-String '<code style=""background:#29464A;color:#F0F0F0; font-size: 13px;font-family: ''Open Sans'';""' -Context 0,1).Context.PostContext" > key.txt
        set /p Key=<key.txt
        echo key: !Key!
    )
)

del temp.txt

endlocal
pause
