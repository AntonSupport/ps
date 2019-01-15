

<#
.SYNOPSIS
вывести основную информацию о компьютере

.DESCRIPTION
Выводит информацию о производителе компьютера, версии операционной системы, и модели материнской платы

.PARAMETER ComputerName
Обязательный параметер.
Используйте localhost для получения данных на компьютере с которого запускается этот скрипт.

.EXAMPLE
Get-SystemInfo -Computer localhost

Пример вывода:

Manufacturer : Gigabyte Technology Co., Ltd.
OSVersion    : 10.0.17134
BIOSSerial   :  
ComputerName : localhost
SPVersion    : 0
Model        : GA-770TA-UD3

#>
function Get-SystemInfo {

    [CmdletBinding()]
     param(
         [Parameter(Mandatory = $True,
                    ValueFromPipeline = $true,
                    HelpMessage = "Computer name or IP address")]
         [ValidateCount(1,10)] # Ограничить прием данных от одного до десяти объектов
         [Alias('Hostname')]
         [string[]]$ComputerName,

         [string]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",

         [switch]$LogErrors
     )

     BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
     }

     PROCESS {
         Write-Verbose "Beginning PROCESS block"
         foreach ($computer in $computername) {
            Write-Verbose "Querying $computer"
            try {
                $no_errors = $True
                $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer -ErrorAction Stop

            }
            Catch {
                $no_errors = $false
                Write-Warning "Поймана ошибка"
                if ($LogErrors) {
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning "Ошибка успешно отправлена в лог файл $errorlog"  
                }
                Write-Error "Компьютер отключен"
            }

            if ($no_errors) {
                $comp = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
                $bios = Get-WmiObject -class Win32_BIOS -computerName $computer
                $props = @{'ComputerName' = $computer;
                    'OSVersion'           = $os.version;
                    'SPVersion'           = $os.servicepackmajorversion;
                    'BIOSSerial'          = $bios.serialnumber;
                    'Manufacturer'        = $comp.manufacturer;
                    'Model'               = $comp.model
                }
                Write-Verbose "WMI queries complete"
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
        }
     }

     END {}
}

"localhost", 'localhost', 'comp1notonline', 'comp2notonline' | Get-SystemInfo -LogErrors -Verbose

<#
Write-Host "---- PIPELINE MODE ----"
'localhost','localhost' | Get-SystemInfo -Verbose
Write-Host "---- PARAM MODE ----"
Get-SystemInfo -ComputerName localhost,localhost -Verbose

Get-SystemInfo -ComputerName one,two,three,four,five,six,
                             seven,eight,nine,ten,eleven

Get-SystemInfo
#>

