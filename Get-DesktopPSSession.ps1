<#
.Synopsis
Скрипт находится в разработке
.DESCRIPTION
Скрипт должен спрашивать credentials или подключатся к компьютеру, или посылать скрипт на удаленный компьютер.
#>
[cmdledBinding()]
Param (
[Parameter(Mandatory = $true, HelpMessage = "Для подключению к компьютеру, предоставьте логин и пароль")]
$session,

$computername = 192.168.1.64,

[Alias("ScriptBlock")]
$command = ''
)

Enter-PSSession -Session $session