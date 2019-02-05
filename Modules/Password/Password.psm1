# Coздать функцию Set-Password, которая будет изменять пароль
# Создать функцию New-Password, Add-Password которая будет создавать новую запись в файле


$kdFile = "$HOME\Documents\kd_list2.csv"

Function Get-Password {
<#
.SYNOPSIS
Поиск пароля по определенным параметрам

.DESCRIPTION
Поиск пароля по таким параметрам как:
Имя -Name
Логин -Login
Электронная почта -Email
Сайт -Website

Так-же для поиска по всем вышеперечисленным критериям используется параметр -Search без ключей:
-Name, Login, Email и Website

.EXAMPLE
Get-Password -Search yandex

Поиск по имени, логину, электронной почты или по названию веб сайта.

.EXAMPLE
Get-Password yandex

Поиск по имени, логину, электронной почты или по названию веб сайта.
Указывать ключик -Search не обязательно так как он является первым.

.EXAMPLE
Get-Password foo@yandex.ru -Email

Осуществить поиск только по Электронной почте.
Следует иметь ввиду, что некоторые сайты используют Email как Логин.
Во избежании неудачного поиска используется два ключа -Email -Login

.EXAMPLE
Get-Password yandex.ru -Name, Login, Email, Website

Поиск по всем возможным параметрам.
#>
    
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [String]$Search,
        [Switch]$Name,
        [Switch]$Login,
        [Switch]$Email,
        [Switch]$Website,
        [Switch]$Id
    )

    $doc = Import-Csv -Path $kdFile -Encoding UTF8

    if (!$Name -and !$Login -and !$Email -and !$Website -and !$Id){
        $doc.Where( { $_.Name -Like "*$Search*" -or
                      $_.Login -Like "*$Search*" -or 
                      $_.Email -Like "*$Search*" -or
                      $_.Website -Like "*$Search*" -or
                      $_.id -eq $search })
    }

    if ($Name) { $doc.Where({$_.Name -like "*$Search*"}) }
    if ($Login) { $doc.Where({$_.Login -like "*$Search*"}) }
    if ($Email) { $doc.Where({$_.Email -like "*$Search*"}) }
    if ($Website) { $doc.Where( {$_.Website -like "*$Search*"}) }
    if ($id) { $doc.Where( {$_.id -eq $search })}
}

Function New-Password {
    <#
.SYNOPSIS
Генератор паролей

.DESCRIPTION
Генерирует пароль из маленьких и больших букв латинского алфавита,
а так-же цифр и спецсимволов.

Копирует новый пароль в буфер обмена

Минимальная длина пароля - 8 знаков
Максимальная длина пароля - 16 знаков

.EXAMPLE
New-Password
VaOhm5I4@p9d

Сгенерировать новый пароль и вывести его в Shell

.EXAMPLE
New-Password -NoSymbols
VaOhm5I4p9d

Сгенерировать новый пароль без спецсимволов

.EXAMPLE
New-Password -Copy

Сгенерировать новый пароль, скопировать в буфер обмена.
При использовании ключа -Copy пароль не выводится в Shell.

#>    
    [cmdletbinding()]
    Param (
        [switch]$NoSymbols,
        [switch]$Copy
    )


    [char[]]$lowletters = "qwertyuiopasdfghjklzxcvbnm"
    [char[]]$upletters = "QWERTYUIOPASDFGHJKLZXCVBNM"
    [char[]]$ints = "1234567890"
    [char[]]$specSmbls = '!@#$%^*()_+=-<>'

    [char[]]$pass = Get-Random -InputObject $lowletters -Count $(Get-Random -Minimum 4 -Maximum 6)
    $pass += Get-Random -InputObject $upletters -Count $(Get-Random -Minimum 2 -Maximum 4)
    $pass += Get-Random -InputObject $ints -Count $(Get-Random -Minimum 2 -Maximum 4)
    if (!$NoSymbols) { $pass += Get-Random -InputObject $specSmbls -Count $(Get-Random -Minimum 1 -Maximum 2) }
    $pass = $pass | sort {Get-Random}
    
    [String]$pass = $pass
    $pass = $pass.Replace(' ', '')

    if ($Copy) { 
        Set-Clipboard $pass  
        return
    }

    $pass
}

Function Add-Password {
    <#
    .SYNOPSIS
    Добавляет новый пароль в ключевой документ
    .DESCRIPTION
    Добавляет новый пароль уже с основными предустановками как email, дата и пароль...
    .EXAMPLE
    Add-Password -name ИмяСайта -login 'somelink@narod.ru'
    Для быстрого добавления пароля.
    .EXAMPLE
    Add-Password -name ИмяСайта -login Anton -Website someSite.com -question 'Любимая живность' -answer ЮЮ -info 'Дополнительная информация'
    Для добавления полной инфы
    .EXAMPLE
    Show-Command Add-Password
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$name,

        [parameter(Mandatory = $true)]
        [string]$login,

        $modifiedDate = '',

        [String]$Website = '',

        [String]$question = '',

        [String]$answer = '',

        [String]$info = ''
    )

    $doc = Import-Csv -Path $kdFile -Encoding UTF8
    [Int]$newID = [int](($doc | Select-Object id -Last 1).id) + 1

    # Date
    $newDate = (Get-Date).ToShortDateString()
    # Whose
    [String]$whose = 'My'
    # Pass
    [String]$pass = New-Password
    # Email
    [String]$email = 'qwsx@mail.ru'
   
    $np = "`"$newID`",`"$newDate`",`"$modifiedDate`",`"$whose`",`"$name`",`"$Website`",`"$login`",`"$pass`",`"$email`",`"$question`",`"$answer`",`"$info`""
    $np | out-file -FilePath $kdFile -Encoding utf8 -Append
    
}

