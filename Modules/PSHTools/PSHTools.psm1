<#
.SYNOPSIS
выводит основную информацию о компьютере

.DESCRIPTION
Выводит основную информацию о компьютере, такую как:
версия операционной системы, производитель компьютера,
модель материнской платы...

.EXAMPLE
laba12 -ComputerName localhost

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
Function laba12 {

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
        Write-Verbose "Начало laba12"}
    PROCESS {
        foreach ($computer in $ComputerName)
        {
            try {
                $no_errors = $true
                $os = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                $no_errors = $false
                Write-Warning "Поймана ошибка в laba12"
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
                    'Computername' = $cs.psComputerName;
                    'Version' = $os.Version;
                    'Model' = $cs.Model;
                    'AdminPass' = $os.AdminPasswordStatus;
                    'ServicePackMV' = $os.ServicePackMajorVersion;
                    'SerialNumber' = $bi.SerialNumber}
                $obj = New-Object -TypeName PSObject -Property $prop
                $obj.PSObject.TypeNames.Insert(0, "MOL.ComputerSystemInfo")
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
                        'Computername' = $cs.psComputerName;
                        'Version' = $os.Version;
                        'Model' = $cs.Model;
                        'AdminPass' = $os.AdminPasswordStatus;
                        'ServicePackMV' = $os.ServicePackMajorVersion;
                        'SerialNumber' = $bi.SerialNumber}
                $obj = New-Object -TypeName PSObject -Property $prop
                $obj.PSObject.TypeNames.Insert(0, "MOL.ComputerSystemInfo")
                $obj
            }
        }
    }
    END {Write-Verbose "Конец laba12"}

}

# ----------------------------------- B -----------------------------

Function construct-labb12 ($d) {
    foreach ($drv in $d) {
        Write-Verbose "Получение данных для диска $($drv.Name)"
        $prop = @{'FreeSpace' = ($drv.FreeSpace / 1GB).ToString("#.##");
            'Drive'                 = $drv.Name;
            'ComputerName'         = $drv.PSComputerName;
            'Size'             = ($drv.Size / 1GB).ToString("#.##")
        }
        
        $obj = New-Object -TypeName PSObject -Property $prop
        $obj.PSObject.TypeNames.Insert(0, "MOL.DiskInfo")
        $obj
    }
}

Function labb12 {
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
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [switch]$LogErrors,

        [String]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",
        
        $Session = $Session
    )

    PROCESS {
        foreach ($c in $ComputerName) {
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
            if ($no_errors) { construct-labb12 ( $($drive | Where-Object DriveType -eq 3) )}
        }

        foreach ($s in $Session ) {
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
            
            if ($no_errors) { construct-labb12( $($drive | Where-Object DriveType -eq 3) )}
        }
    }
    END {Write-Verbose "Конец labb12"}
}

# ------------------------------- C -------------------------------

Function construct-labc12 ($serv) {
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
        $obj.PSObject.TypeNames.Insert(0, 'MOL.ServiceProcessInfo')
        $obj
     }
}

Function labc12 {

    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [string]$ErrorLog = "$HOME\Desktop\Get_SystemInfo_ErrorLog.txt",

        [switch]$LogErrors,

        $session = $session
    )

    BEGIN{Write-Verbose "Начало labc12"}
    
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
                construct-labc12 ($($service | Where-Object State -eq "Running"))
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
                construct-labc12 ($($service | Where-Object State -eq "Running"))
            }            
        }
    }

    END{
        if($no_errors){
            Get-ChildItem -Path $ErrorLog | Remove-Item
        }
    }
}