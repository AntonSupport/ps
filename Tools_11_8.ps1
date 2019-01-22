Function Get-ServiceInfo {
    [cmdletbinding()]
    Param(
        [string]$Computername)

    $services = Get-WmiObject -Class Win32_Service -filter "state -eq 'Running'" -computername $computername
    Write-Host "Found ($services.count) on $computername" -ForegroundColor Green
    $services | sort -Property startname, name | Select -property `
        startname, name, startmode, computername
}

Get-ServiceInfo localhost