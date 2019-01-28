
$MOLErrorLogPreference = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt"

<#
.SYNOPSIS
вывести основную информацию о компьютере

.DESCRIPTION
Выводит информацию о производителе компьютера, версии операционной системы, и модели материнской платы

.PARAMETER ComputerName
Обязательный параметер.
Используйте localhost для получения данных на компьютере с которого запускается этот скрипт.

.EXAMPLE
Get-MOLSystemInfo -Computer localhost

Пример вывода:

Manufacturer : Gigabyte Technology Co., Ltd.
OSVersion    : 10.0.17134
BIOSSerial   :  
ComputerName : localhost
SPVersion    : 0
Model        : GA-770TA-UD3

#>
function Get-MOLSystemInfo {

    [CmdletBinding()]
     param(
         [Parameter(Mandatory = $True,
                    ValueFromPipeline = $true,
                    HelpMessage = "Computer name or IP address")]
         [ValidateCount(1,10)] # Ограничить прием данных от одного до десяти объектов
         [Alias('Hostname')]
         [string[]]$ComputerName,

         [string]$ErrorLog = $MOLErrorLogPreference,

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
                $obj.PSObject.TypeNames.Insert(0,'MOL.SystemInfo')
                Write-Output $obj
            }
        }
     }

     END {}
}

Export-ModuleMember -Variable MOLErrorLogPreference
Export-ModuleMember -Function Get-MOLSystemInfo