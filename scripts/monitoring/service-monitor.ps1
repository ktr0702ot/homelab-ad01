foreach ($item in $serviceList) {

    $server = $item.Server
    $serviceName = $item.Service

    $service = Get-Service -ComputerName $server -Name $serviceName

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($service.Status -eq "Running") {
        $message = "$timestamp OK $server $serviceName Running"
    }
    else {
        $message = "$timestamp ALERT $server $serviceName $($service.Status)"
    }

    $message
    Add-Content -Path $logPath -Value $message
}
