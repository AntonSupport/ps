
Param (
$ComputerName = '192.168.1.64', # Адрес домашнего настольного компьютера A1.
$UserName = 'Anton'
)

if (!$cred)
{
    Write-Verbose "Запрашиваем логин и пароль к компьютеру"
    New-Variable -Name cred -Value ( Get-Credential -UserName $UserName -Message "Пароль к домашнему компьютеру A1:" ) -Scope "Global"
    New-Variable -Name session -Value ( New-PSSession -ComputerName $ComputerName -Credential $cred ) -Scope "Global"
}

Get-PSSession

Enter-PSSession -Session $session