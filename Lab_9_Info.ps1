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

         [string]$ErrorLog = "$HOME\Desktop\retry.txt",

         [switch]$LogErrors
     )

     BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
     }

     PROCESS {
         Write-Verbose "Beginning PROCESS block"
         foreach ($computer in $computername) {
         Write-Verbose "Querying $computer"
         $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer
         $comp = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
         $bios = Get-WmiObject -class Win32_BIOS -computerName $computer
         $props = @{'ComputerName'=$computer;
                    'OSVersion'=$os.version;
                    'SPVersion'=$os.servicepackmajorversion;
                    'BIOSSerial'=$bios.serialnumber;
                    'Manufacturer'=$comp.manufacturer;
                    'Model'=$comp.model}
         Write-Verbose "WMI queries complete"
         $obj = New-Object -TypeName PSObject -Property $props
         Write-Output $obj
        }
     }

     END {}
}



<#
Get-SystemInfo -comp localhost -Verbose
"localhost", 'localhost' | Get-SystemInfo

Write-Host "---- PIPELINE MODE ----"
'localhost','localhost' | Get-SystemInfo -Verbose
Write-Host "---- PARAM MODE ----"
Get-SystemInfo -ComputerName localhost,localhost -Verbose

Get-SystemInfo -ComputerName one,two,three,four,five,six,
                             seven,eight,nine,ten,eleven

Get-SystemInfo
#>


<#
.SYNOPSIS
выводит основную информацию о компьютере

.DESCRIPTION
Выводит основную информацию о компьютере, такую как:
версия операционной системы, производитель компьютера,
модель материнской платы...

.EXAMPLE
laba9 -ComputerName localhost

Вывод:

Version       : 10.0.17134
Manufacturer  : Gigabyte Technology Co., Ltd.
Workgroup     : WORKGROUP
Computer name : A1
ServicePackMV : 0
AdminPass     : 
Model         : GA-770TA-UD3
SerialNumber  : 00331-10000-00001-AA022
#>
Function laba9 {

    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [System.Management.Automation.Runspaces.PSSession]
        $session = $session
    )

    BEGIN {
        Write-Verbose "Начало laba9"}
    PROCESS {
        foreach ($computer in $ComputerName)
        {
            Write-Verbose "Получаем данные для $computer"
            $os = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
            Write-Verbose "Win32_Operatingsystem"
            $cs = Get-WmiObject Win32_ComputerSystem -ComputerName $Computer
            Write-Verbose "Win32_Computersystem"
            $bi = Get-WmiObject Win32_BIOS -ComputerName $Computer
            Write-Verbose "Win32_BIOS"
            $prop = @{'Workgroup'= $cs.workgroup;
                  'Manufacturer' = $cs.manufacturer;
                  'Computer name' = $cs.psComputerName;
                  'Version' = $os.Version;
                  'Model' = $cs.Model;
                  'AdminPass' = $os.AdminPasswordStatus;
                  'ServicePackMV' = $os.ServicePackMajorVersion;
                  'SerialNumber' = $os.SerialNumber}
            $obj = New-Object -TypeName PSObject -Property $prop
            $obj
        }
        foreach ($s in $session) {
            $os = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject Win32_OperatingSystem }
            $cs = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject Win32_ComputerSystem }
            $bi = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject Win32_BIOS }
            $prop = @{'Workgroup'= $cs.workgroup;
                  'Manufacturer' = $cs.manufacturer;
                  'Computer name' = $cs.psComputerName;
                  'Version' = $os.Version;
                  'Model' = $cs.Model;
                  'AdminPass' = $os.AdminPasswordStatus;
                  'ServicePackMV' = $os.ServicePackMajorVersion;
                  'SerialNumber' = $os.SerialNumber}
            $obj = New-Object -TypeName PSObject -Property $prop
            $obj
        }
    }
    END {Write-Verbose "Конец laba9"}

}

<#
laba9 -ComputerName localhost, localhost
'localhost' | laba9 -Verbose
laba9
#>

Function construct-labb8 ($d){
    foreach ($drv in $d){
        Write-Verbose "Получение данных для диска $($drv.Name)"
        $prop = @{'Free Space (GB)' = ($drv.FreeSpace / 1GB).ToString("#.##");
                    'Drive' = $drv.Name;
                    'Computer Name' = $drv.PSComputerName;
                    'Size (GB)' = ($drv.Size / 1GB).ToString("#.##") }
        
        $obj = New-Object -TypeName PSObject -Property $prop
        $obj
        }
}

Function labb8 {
<#
.SYNOPSIS
Показывает информацию о дисковом пространстве

.DESCRIPTION

Free Space (GB) Drive Computer Name Size (GB)
--------------- ----- ------------- ---------
78,77           C:    A1            297,24   
102,4           D:    A1            838,38   
79,35           E:    A1            89,22 
#>
    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,
        $Session = $Session
    )

    BEGIN{}
    PROCESS{
        foreach ($c in $ComputerName){
            $drive = Get-WmiObject -Class CIM_LogicalDisk -ComputerName $c | where DriveType -eq 3
            construct-labb8 ($drive)
        }

        foreach ($s in $Session ){
            $drive = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class CIM_LogicalDisk }
            construct-labb8($drive)
        }
    }
    END{Write-Verbose "Конец labb8"} 
}

<#
labb8 -ComputerName localhost
'localhost' | labb8 -Verbose
#>

Function construct-labc8 ($serv) {
    foreach ( $s in $serv ) {
        Write-Verbose "Получаем информацию для сервиса $($s.Name)"
        $id = $s | Select-Object -ExpandProperty ProcessId
        $proc = Get-WmiObject Win32_Process | where ProcessId -eq $id

        $prop = [ordered]@{
                    'ComputerName' = $s.pscomputername;
                    'ThreadCount' = $proc.ThreadCount;
                    'ProcessName' = $proc.ProcessName;
                    'ServiceName' = $s.Name;
                    'VMSize' = $proc.VirtualSize;
                    'PeakPageFile' = $proc.PeakPageFileUsage;
                    'ProcessDescription' = $proc.Description }
                           
        $obj = New-Object -TypeName PSObject -Property $prop
        $obj
     }
}

Function labc8 {

    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        $session = $session
    )

    BEGIN{Write-Verbose "Начало labc8"}
    
    PROCESS {
        foreach ( $c in $ComputerName ) {
            Write-Verbose "Получаем информацию о сервисах компьютера $c"
            $service = Get-WmiObject -Class Win32_Service -ComputerName $c | where State -eq "Running"
            construct-labc8 ($service)
        }

        foreach ($s in $session) {
            Write-Verbose "Получаем информацию о сервисах компьютера $c"
            $service = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class Win32_Service | where State -eq "Running" }
            construct-labc8 ($service)
        }
    }

    END{}
}

# labc8 -ComputerName localhost | select computername, servicename, processname, processdescription
# labc7 -ComputerName localhost | Export-Csv -Path C:\Users\Администратор.WIN-998J9J870LA\Desktop\services.csv
# 'localhost' | labc8 -Verbose

function Standalone_lab_8 {
<#
.SYNOPSIS
Показать основную информацию о компьютере

.DESCRIPTION
Показывает основную информацию о компьютере, такую как:
Имя компьютера, последнее время загрузки,
версия операционной системы, производитель
а так же модель компьютера
#>
  
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName
    )
    
    PROCESS {
        foreach ($computer in $computerName) {
            Write-Verbose "Получаем WMI данные для $computer"
            $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer
            $cs = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
            $props = @{'ComputerName'=$computer;
                       'LastBootTime'=($os.ConvertToDateTime($os.LastBootupTime));
                       'OSVersion'=$os.version;
                       'Manufacturer'=$cs.manufacturer;
                       'Model'=$cs.model}

            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
    }
}

# Standalone_lab_8 -ComputerName localhost
# 'localhost','localhost' | Standalone_lab_8 -Verbose


