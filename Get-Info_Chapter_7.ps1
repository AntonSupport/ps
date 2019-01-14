Function Get-Info {
    
    $os = Get-WmiObject Win32_OperatingSystem
    $cs = Get-WmiObject Win32_ComputerSystem

    New-Object
    
    Write-Output @{ 'Name' = $os.Name }       # Имя компьютера
      #  @{ l = 'WG' ; e = { $cs.Workgroup }}    # Рабочая группа

    $result
}

Function Get-SystemInfo {
    
    [CmdletBinding()]
    Param (
        [String[]]$computerName = 'localhost',

        [String]$errorLog
    )


    BEGIN {}
    PROCESS {
        foreach ($computer in $computerName) {
            $os = Get-WmiObject -Class Win32_OperatingSystem `
                -ComputerName $computer
            $comp = Get-WmiObject -Class Win32_ComputerSystem `
                -ComputerName $computer
            $bios = Get-WmiObject -Class Win32_BIOS `
                -ComputerName $computer

            $props = @{'ComputerName' = $computer;
                     'OSVersion' = $os.version ;
                     'SPVersion' = $os.servicepackmajorversion;
                     'BIOSSerial' = $bios.serialnumber;
                     'Manufacturer' = $comp.manufacturer;
                     'Model' = $comp.model}
            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj

            }
        }
    END {}


}

# Get-SystemInfo -computerName localhost, localhost -errorLog x.txt

# Get-Info


Function laba7 {

    [cmdletbinding()]
    Param (
        [String[]]$ComputerName,

        [System.Management.Automation.Runspaces.PSSession]
        $session = $session
    )

    BEGIN {}
    PROCESS {
        foreach ($computer in $ComputerName)
        {
            $os = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
            $cs = Get-WmiObject Win32_ComputerSystem -ComputerName $Computer
            $bi = Get-WmiObject Win32_BIOS -ComputerName $Computer
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
    END {}

}

# laba7 -ComputerName localhost, localhost

Function construct-labb7 ($d){
    foreach ($drv in $d){
        $prop = @{'Free Space (GB)' = ($drv.FreeSpace / 1GB).ToString("#.##");
                    'Drive' = $drv.Name;
                    'Computer Name' = $drv.PSComputerName;
                    'Size (GB)' = ($drv.Size / 1GB).ToString("#.##") }
        
        $obj = New-Object -TypeName PSObject -Property $prop
        $obj
        }
}

Function labb7 {

    [cmdletbinding()]
    Param (
        [String[]]$ComputerName,
        $Session = $Session
    )

    foreach ($c in $ComputerName){
        $drive = Get-WmiObject -Class CIM_LogicalDisk -ComputerName $c | where DriveType -eq 3
        construct-labb7 ($drive)
    }

    foreach ($s in $Session ){
        $drive = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class CIM_LogicalDisk }
        construct-labb7($drive)
    } 
}

# labb7 -ComputerName localhost


Function construct-labc7 ($serv) {
    foreach ( $s in $serv ) {
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

Function labc7 {

    [cmdletbinding()]
    Param (
        [String[]]$ComputerName,

        $session = $session
    )

    foreach ( $c in $ComputerName ) {
        $service = Get-WmiObject -Class Win32_Service -ComputerName $c | where State -eq "Running"
        construct-labc7 ($service)
    }

    foreach ($s in $session) {
        $service = Invoke-Command -Session $s -ScriptBlock { Get-WmiObject -Class Win32_Service | where State -eq "Running" }
        construct-labc7 ($service)
    }
}

# labc7 -ComputerName localhost | select computername, servicename, processname, processdescription
# labc7 -ComputerName localhost | Export-Csv -Path C:\Users\Администратор.WIN-998J9J870LA\Desktop\services.csv

Function construct-standalonelab7() {
    $time = $os.LastBootUpTime
    $time = (Get-WmiObject -Class Win32_OperatingSystem).ConvertToDateTime($time)
    $prop = @{  'LastBoot' = $time
                'ComputerName' = $os.PSComputerName
                'OperatingSystem' = $os.Caption
                'OSVersion' = $os.Version
                'Manufacturer' = $comp.Manufacturer
                'Model' = $comp.Model}

        $obj = New-Object -TypeName PSObject -Property $prop
        $obj
       
}

Function standalonelab7 {

    [cmdletbinding()]
    Param (
        [String[]]$ComputerName,
        $session = $session
    )

    foreach ($c in $ComputerName){
        $comp = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $c
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $c
        construct-standalonelab7       
    }

    foreach ($s in $session){
        $comp = Invoke-Command -Session $session -ScriptBlock { Get-WmiObject -Class Win32_ComputerSystem }
        $os = Invoke-Command -Session $session -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem }
        construct-standalonelab7
    }

}

# standalonelab7 -ComputerName localhost


