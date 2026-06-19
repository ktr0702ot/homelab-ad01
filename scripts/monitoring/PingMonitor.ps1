$Targets = @("AD01", "FILE01", "BK01", "CLIENT01")
$LogPath = "C:\Monitor\ping-monitor.log"

foreach ($Target in $Targets) {

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if (Test-Connection $Target -Count 1 -Quiet) {

        "$Time : $Target OK" | Out-File $LogPath -Append

    }
    else {

        "$Time : $Target NG !!!" | Out-File $LogPath -Append

        Write-Host "ALERT : $Target is DOWN" -ForegroundColor Red

    }
}
