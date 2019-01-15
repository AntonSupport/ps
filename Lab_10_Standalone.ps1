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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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
                if ($LogErrors) {
                    Write-Warning -Message "Запись $computer в лог файл $ErrorLog"
                    $computer | Out-File $ErrorLog -Append
                }               
            }
            
            if ($no_errors) {
                $cs = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
                $props = @{'ComputerName' = $computer;
                    'LastBootTime'        = ($os.ConvertToDateTime($os.LastBootupTime));
                    'OSVersion'           = $os.version;
                    'Manufacturer'        = $cs.manufacturer;
                    'Model'               = $cs.model
                }
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
        }
    }

    END {
        if ($no_errors) {
            Get-ChildItem -Path $ErrorLog | Remove-Item
        }
    }
}

# Standalone_lab_10 -ComputerName localhost -LogErrors -Verbose
Standalone_lab_10 -ComputerName localhost, NOTONLINE -LogErrors -Verbose
# 'localhost','localhost' | Standalone_lab_8 -Verbose