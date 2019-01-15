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





# "localhost", 'localhost', 'comp1notonline', 'comp2notonline' | Get-SystemInfo -LogErrors -Verbose

<#
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
laba10 -ComputerName localhost

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
Function laba10 {

    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [System.Management.Automation.Runspaces.PSSession]
        $session = $session,

        [String]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",

        [switch]$LogErrors
    )

    BEGIN {
        Write-Verbose "Начало laba10"}
    PROCESS {
        foreach ($computer in $ComputerName)
        {
            try {
                $no_errors = $true
                Write-Verbose "Получаем данные для $computer"
                $os = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning "Поймана ошибка в Laba10"
                if ($LogErrors) {
                    Write-Warning "Компьютер $computer добавлен в лог файл $ErrorLog"
                    $computer | Out-File $ErrorLog -Append
                }
                Write-Error -Message "Компьютер $Computer недоступен"
            }
            
            if ($no_errors) {
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
        }
        foreach ($s in $session) {
            try {
                $no_errors = $true
                Write-Verbose "Win32_Operatingsystem"
                $os = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject Win32_OperatingSystem } -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning -Message "Поймана ошибка для Сессии $s"
                if ($LogErrors) {
                    Write-Warning -Message "Запись сессии $s в лог файл $ErrorLog"
                    $s | Out-File $ErrorLog -Append
                }
                Write-Error -Message "Компьютер $s недоступен"
            }
            
            if ($no_errors){
                Write-Verbose "Win32_Computersystem"
                $cs = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject Win32_ComputerSystem }
                Write-Verbose "Win32_BIOS"
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
    }
    END {Write-Verbose "Конец laba10"}

}
# 'localhost', 'notonline2' | laba10 -LogErrors -Verbose

<#
laba10 -ComputerName localhost, localhost
laba10
#>

Function construct-labb10 ($d){
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

Function labb10 {
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

        [switch]$LogErrors,

        [String]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",
        
        $Session = $Session
    )

    PROCESS{
        foreach ($c in $ComputerName){
            try {
                $no_errors = $true
                $drive = Get-WmiObject -Class CIM_LogicalDisk -ComputerName $c -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning "Ошибка на $c"
                if ($LogErrors) {
                    Write-Warning -Message "Запись компьютера $c в лог файл $ErrorLog"
                    $c | Out-File $ErrorLog -Append
                }
                
            }
            if($no_errors) { construct-labb10 ( $($drive | Where-Object DriveType -eq 3) )}
        }

        foreach ($s in $Session ){
            try {
                $no_errors = $true
                $drive = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class CIM_LogicalDisk } -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning -Message "Ошибка на $s"
                if ($LogErrors) {
                    Write-Warning -Message "Запись компьютера $c в лог файл $ErrorLog"
                    $s | Out-File -FilePath $ErrorLog -Append
                }
            }
            
            if($no_errors) { construct-labb10( $($drive | Where-Object DriveType -eq 3) )}
        }
    }
    END{Write-Verbose "Конец labb10"} 
}

# labb10 -ComputerName localhost, notonlinebb10 -LogErrors -Verbose

<#
labb10 -ComputerName localhost
'localhost' | labb10 -Verbose
#>

Function construct-labc10 ($serv) {
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

Function labc10 {

    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [string]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",

        [switch]$LogErrors,

        $session = $session
    )

    BEGIN{Write-Verbose "Начало labc10"}
    
    PROCESS {
        foreach ( $c in $ComputerName ) {
            
            try {
                Write-Verbose "Получаем информацию о сервисах компьютера $c"
                $no_errors = $true
                $service = Get-WmiObject -Class Win32_Service -ComputerName $c -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning -Message "Ошибка на $c"
                if ($LogErrors) {
                    Write-Warning -Message "Запись в файл $ErrorLog"
                    $c | Out-File -FilePath $ErrorLog -Append
                }
            }

            if ($no_errors) {
                construct-labc10 ($($service | Where-Object State -eq "Running"))
            }   
        }

        foreach ($s in $session) {
        
            try {
                Write-Verbose "Получаем информацию о сервисах компьютера $c"
                $no_errors = $true
                $service = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class Win32_Service } -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning -Message "Ошибка на $s"
                $s | Out-File -FilePath $ErrorLog -Append
                Write-Error -Message "Компьютер $s недоступен"
            }
            
            if ($no_errors) {
                construct-labc10 ($($service | Where-Object State -eq "Running"))
            }            
        }
    }

    END{
        if($no_errors){
            Get-ChildItem -Path $ErrorLog | Remove-Item
        }
    }
}

# labc10 -ComputerName localhost, notonline11 -LogErrors -Verbose

# labc10 -ComputerName localhost | select computername, servicename, processname, processdescription
# labc7 -ComputerName localhost | Export-Csv -Path C:\Users\Администратор.WIN-998J9J870LA\Desktop\services.csv
# 'localhost' | labc10 -Verbose

function Standalone_lab_10 {
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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [string]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",

        [switch]$LogErrors
    )
    
    PROCESS {
        foreach ($computer in $computerName) {

            Write-Verbose "Получаем WMI данные для $computer"
            try {
                $no_errors = $true
                $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning -Message "Компьютер $computer не отвечает"
                if ($LogErrors){
                    Write-Warning -Message "Запись $computer в лог файл $ErrorLog"
                    $computer | Out-File $ErrorLog -Append
                }               
            }
            
            if ($no_errors){
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

    END {
        if ($no_errors){
            Get-ChildItem -Path $ErrorLog | Remove-Item
        }
    }
}
# Standalone_lab_10 -ComputerName localhost -LogErrors -Verbose

Standalone_lab_10 -ComputerName localhost, NOTONLINE -LogErrors -Verbose
# 'localhost','localhost' | Standalone_lab_8 -Verbose

