

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
                Write-Warning "Поймана ошибка в laba10"
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
                    'SerialNumber' = $bi.SerialNumber}
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

'localhost', 'notonline2' | laba10 -LogErrors -Verbose

<#
laba10 -ComputerName localhost, localhost
laba10
#>