

Function Get-RemoteSmbShare {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Введите имя компьютера или IP")]
        [Alias('HostName')]
        [string[]]$ComputerName
        
    )
}

Get-RemoteSmbShare –computerName localhost, localhost


# Section 15.3 Tests...
'localhost','localhost' | Get-RemoteSmbShare
Get-RemoteSmbShare –host localhost
# The following should prompt for a name; enter localhost
Get-RemoteSmbShare
# The following should fail with an error
Get-RemoteSmbShare –Computer one, two, three, four, five, six, seven





Invoke-CimMethod –ClassName Win32_OperatingSystem –MethodName Reboot –ComputerName localhost -WhatIf
