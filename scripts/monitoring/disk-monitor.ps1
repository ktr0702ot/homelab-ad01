$servers = @("AD01", "FILE01", "BK01", "MON01")
$logPath = "C:\Monitor\Logs\disk.log"

foreach ($server in $servers) {
    $disk = Get-CimInstance Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='C:'"

    $usedPercent = (($disk.Size - $disk.FreeSpace) / $disk.Size) * 100
    $usedPercent = [math]::Round($usedPercent, 0)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($usedPercent -ge 80) {
        $message = "$timestamp ALERT $server C: Used $usedPercent%"
    }
    else {
        $message = "$timestamp OK $server C: Used $usedPercent%"
    }

    $message
    Add-Content -Path $logPath -Value $message
}
