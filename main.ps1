$checkpoints = @(
    "https://flux.li/windows/start.php?updated_browser=true",
    "https://fluxteam.net/windows/checkpoint/check1.php",
    "https://fluxteam.net/windows/checkpoint/check2.php",
    "https://fluxteam.net/windows/checkpoint/main.php"
)

$HwProfileGuid = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001").HwProfileGuid
$HwProfileGuid = $HwProfileGuid -replace '[{}]','' -replace '-',''

$SystemManufacturer = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation").SystemManufacturer

$HWID = $HwProfileGuid + $SystemManufacturer

Write-Host "HwProfileGuid: $HwProfileGuid"
Write-Host "SystemManufacturer: $SystemManufacturer"
Write-Host "HWID: $HWID"
Write-Host ""
Write-Host "Starting checkpoints..."
Write-Host ""

$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:113.0) Gecko/20100101 Firefox/113.0"

for ($i = 0; $i -le 3; $i++) {
    if ($i -eq 0) {
        $Referer = "https://flux.li/windows/start.php"
    } else {
        $Referer = "https://linkvertise.com/"
    }

    Invoke-RestMethod -Uri $checkpoints[$i] -Headers @{"User-Agent" = $UserAgent; "Referer" = $Referer} -Method Post -Body "HWID=$HWID" -OutFile "temp.txt"

    if ($i -eq 3) {
        $content = Get-Content "temp.txt"
        $Key = $content | Select-String -Pattern '<code style="background:#29464A;color:#F0F0F0; font-size: 13px;font-family: ''Open Sans'';"' -Context 0,1 | Select-Object -ExpandProperty Context | Out-File "key.txt"
        Write-Host "key: $Key"
    }
}

Remove-Item "temp.txt"

Write-Host ""
Write-Host "The key is the random string.."
Get-Content "key.txt"

pause
