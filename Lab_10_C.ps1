


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

labc10 -ComputerName localhost, notonline11 -LogErrors -Verbose

# labc10 -ComputerName localhost | select computername, servicename, processname, processdescription
# labc7 -ComputerName localhost | Export-Csv -Path C:\Users\Администратор.WIN-998J9J870LA\Desktop\services.csv
# 'localhost' | labc10 -Verbose