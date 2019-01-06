<#
.Synopsis
Показывает информацию о сетевой карточки
.DESCRIPTION
Показывает полную информацию о встроенных сетевых карточках
.EXAMPLE
22.ps1 -computername localhost

Обязательным параметром в этом примере localhost

.EXAMPLE
22.ps1 hostname localhost

Обязательным параметром в этом примере является hostname,
который является псевдонимом computername
#>

[cmdletBinding()]
Param (
[Parameter(Mandatory=$true)]
[Alias('hostname')]
$computername
)
Write-Verbose "Получение информации о физических сетевых картах с компьютера $computername"
get-wmiobject win32_networkadapter -computername localhost |
    where { $_.PhysicalAdapter } |
    select MACAddress, AdapterType, DeviceID, Name, @{l='Speed';e={$_.Speed / 1MB -as [INT]}}
Write-Verbose "Выведена информация о физических сетевых картах установленных на компьютере $computername"