
Param (
    # $ComputerName = '192.168.1.64', # Адрес домашнего настольного компьютера A1.
    $ComputerName = '192.168.56.3', # Адрес виртуального сервера.
    # $UserName = 'Anton'
    $UserName = 'Администратор'
)

if (!$cred -and !$session) {
    Write-Verbose "Запрашиваем логин и пароль к компьютеру"
    New-Variable -Name cred -Value ( Get-Credential -UserName $UserName -Message "Пароль к домашнему компьютеру A1:" ) -Scope "Global"
    New-Variable -Name session -Value ( New-PSSession -ComputerName $ComputerName -Credential $cred ) -Scope "Global"
}
else {
    Remove-Variable -Name cred, session -Scope "Global"
}

Get-PSSession

Enter-PSSession -Session $session