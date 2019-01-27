
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

Update-FormatData –prepend ./CustomViewB.format.ps1xml
labb12 -ComputerName localhost

<#
labb12 -ComputerName localhost
'localhost' | labb12 -Verbose
#>
